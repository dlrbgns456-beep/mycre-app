-- ══════════════════════════════════════════════════════════
-- Supabase 보안 어드바이저 4건 수정
-- 실행 위치: Supabase Dashboard → SQL Editor
-- 적용일: 2026-04-29
-- ══════════════════════════════════════════════════════════
-- 발견된 이슈:
--   1) Exposed Auth Users — user_reputation 뷰가 auth.users 직접 노출
--   2) Security Definer View — user_reputation 뷰가 호출자 권한 무시
--   3) Disabled RLS — post_reports 테이블 RLS 미활성화
--   4) Disabled RLS — notification_log 테이블 RLS 미활성화
-- ══════════════════════════════════════════════════════════

-- 1) user_reputation: SECURITY INVOKER + auth.users 노출 제거
DROP VIEW IF EXISTS public.user_reputation;
CREATE VIEW public.user_reputation
WITH (security_invoker = true) AS
SELECT
  p.id AS user_id,
  COALESCE(AVG(r.rating), 0)::NUMERIC AS avg_rating,
  COUNT(DISTINCT r.id) AS review_count,
  COUNT(DISTINCT rep.id) AS report_count,
  (COUNT(DISTINCT rep.id) >= 3) AS is_flagged
FROM public.profiles p
LEFT JOIN public.seller_reviews r ON r.seller_id = p.id
LEFT JOIN public.post_reports rep ON rep.reported_user_id = p.id
GROUP BY p.id;

GRANT SELECT ON public.user_reputation TO authenticated, anon;

-- 2) post_reports RLS
ALTER TABLE public.post_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reporter can insert own report" ON public.post_reports;
CREATE POLICY "Reporter can insert own report" ON public.post_reports
  FOR INSERT TO authenticated
  WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Reporter or admin can read" ON public.post_reports;
CREATE POLICY "Reporter or admin can read" ON public.post_reports
  FOR SELECT TO authenticated
  USING (
    reporter_id = auth.uid()
    OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
  );

DROP POLICY IF EXISTS "Reporter can delete own report" ON public.post_reports;
CREATE POLICY "Reporter can delete own report" ON public.post_reports
  FOR DELETE TO authenticated
  USING (
    reporter_id = auth.uid()
    OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
  );

DROP POLICY IF EXISTS "Admin can update reports" ON public.post_reports;
CREATE POLICY "Admin can update reports" ON public.post_reports
  FOR UPDATE TO authenticated
  USING ((auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com')
  WITH CHECK ((auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com');

-- 3) notification_log RLS (시스템은 service_role로 INSERT, 사용자는 SELECT만)
ALTER TABLE public.notification_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own notification log" ON public.notification_log;
CREATE POLICY "Users can read own notification log" ON public.notification_log
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
  );

-- ══════════════════════════════════════════════════════════
-- 검증
-- ══════════════════════════════════════════════════════════
-- SELECT c.relname, c.relkind, c.relrowsecurity
-- FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
-- WHERE n.nspname='public' AND c.relname IN ('user_reputation','post_reports','notification_log');
