-- ══════════════════════════════════════════════════════════
-- posts.is_verified 위변조 방지 RLS
-- 실행 위치: Supabase Dashboard → SQL Editor
-- 적용일: 2026-04-28
-- ══════════════════════════════════════════════════════════
--
-- 목적:
-- 클라이언트 측 코드는 자기 개체와 연결된 게시글에만
-- is_verified=true를 설정하지만, DevTools 등으로 페이로드를
-- 조작하면 가짜 인증 배지를 달 수 있음.
-- DB RLS 레이어에서 다음 조건만 허용하도록 강제:
--   1) is_verified=false (또는 NULL) — 누구나 INSERT/UPDATE 가능
--   2) is_verified=true 이고 linked_gecko_id가 본인 소유 개체
--   3) is_verified=true 이고 작성자가 관리자 이메일
-- ══════════════════════════════════════════════════════════

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Verified flag must match ownership or admin (insert)" ON posts;
CREATE POLICY "Verified flag must match ownership or admin (insert)"
ON posts
AS RESTRICTIVE
FOR INSERT
TO authenticated
WITH CHECK (
  COALESCE(is_verified, false) = false
  OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
  OR (
    linked_gecko_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM geckos g
      WHERE g.id = posts.linked_gecko_id::TEXT
        AND g.user_id = auth.uid()
    )
  )
);

DROP POLICY IF EXISTS "Verified flag must match ownership or admin (update)" ON posts;
CREATE POLICY "Verified flag must match ownership or admin (update)"
ON posts
AS RESTRICTIVE
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (
  COALESCE(is_verified, false) = false
  OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
  OR (
    linked_gecko_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM geckos g
      WHERE g.id = posts.linked_gecko_id::TEXT
        AND g.user_id = auth.uid()
    )
  )
);

-- ══════════════════════════════════════════════════════════
-- 확인 쿼리
-- ══════════════════════════════════════════════════════════
-- SELECT policyname, cmd, permissive, qual, with_check
--   FROM pg_policies
--  WHERE tablename = 'posts' AND policyname LIKE '%Verified%';
--
-- 테스트:
-- 1) 일반 유저로 로그인 + DevTools에서 다음 호출:
--    INSERT INTO posts (user_id, cat, title, is_verified)
--    VALUES (auth.uid(), 'sale', '가짜', true);
--    → permission denied / row-level security 에러 발생해야 함
-- 2) 본인 소유 개체 ID를 linked_gecko_id로 함께 보내면 통과
-- 3) 관리자 계정(dlrbgns456@gmail.com)은 linked_gecko_id 없어도 통과
