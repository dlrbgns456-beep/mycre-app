-- ============================================================
-- 보안 강화 (2026-06-05)
--  1) 개인정보(전화/사업자번호) → profiles_private 분리 (본인/관리자만)
--  2) geckos SELECT → 본인 OR 관리자 (경쟁자 스크래핑 차단)
--  3) 공유 카드용 SECURITY DEFINER 함수 (안전 컬럼만 노출)
--  ※ 전 구간 멱등(idempotent) — 재실행해도 안전
-- ============================================================

-- ── 1) 민감정보 분리 테이블 ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles_private (
  id                uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone_number      text,
  phone_verified_at timestamptz,
  biz_number        text,
  updated_at        timestamptz DEFAULT now()
);

ALTER TABLE public.profiles_private ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pp_select_own   ON public.profiles_private;
CREATE POLICY pp_select_own   ON public.profiles_private
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS pp_select_admin ON public.profiles_private;
CREATE POLICY pp_select_admin ON public.profiles_private
  FOR SELECT USING ((auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com');

DROP POLICY IF EXISTS pp_insert_own   ON public.profiles_private;
CREATE POLICY pp_insert_own   ON public.profiles_private
  FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS pp_update_own   ON public.profiles_private;
CREATE POLICY pp_update_own   ON public.profiles_private
  FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- ── 2) 기존 데이터 이관 + profiles 에서 민감 컬럼 제거 ──────
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='profiles' AND column_name='phone_number'
  ) THEN
    INSERT INTO public.profiles_private (id, phone_number, phone_verified_at, biz_number)
    SELECT id, phone_number, phone_verified_at, biz_number
    FROM public.profiles
    WHERE phone_number IS NOT NULL OR biz_number IS NOT NULL OR phone_verified_at IS NOT NULL
    ON CONFLICT (id) DO UPDATE SET
      phone_number      = COALESCE(EXCLUDED.phone_number,      public.profiles_private.phone_number),
      phone_verified_at = COALESCE(EXCLUDED.phone_verified_at, public.profiles_private.phone_verified_at),
      biz_number        = COALESCE(EXCLUDED.biz_number,        public.profiles_private.biz_number);

    ALTER TABLE public.profiles DROP COLUMN IF EXISTS phone_number;
    ALTER TABLE public.profiles DROP COLUMN IF EXISTS phone_verified_at;
    ALTER TABLE public.profiles DROP COLUMN IF EXISTS biz_number;
  END IF;
END $$;

-- ── 3) geckos SELECT 잠금 (본인 OR 관리자) ──────────────────
DROP POLICY IF EXISTS geckos_select_public_by_id ON public.geckos;
DROP POLICY IF EXISTS geckos_select_own           ON public.geckos;
CREATE POLICY geckos_select_own ON public.geckos
  FOR SELECT USING (
    auth.uid() = user_id
    OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
  );

-- ── 4) 공유 카드용 함수 (안전 컬럼만, RLS 우회) ─────────────
CREATE OR REPLACE FUNCTION public.get_shared_gecko(p_gecko_id text, p_owner_id uuid)
RETURNS TABLE (
  name text, morph text, sex text, dob text,
  weight text, dad text, mom text, photo text, status text
)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT name, morph, sex, dob, weight, dad, mom, photo, status
  FROM public.geckos
  WHERE id = p_gecko_id AND user_id = p_owner_id
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.get_shared_gecko(text, uuid) FROM public;
GRANT  EXECUTE ON FUNCTION public.get_shared_gecko(text, uuid) TO anon, authenticated;
