-- ══════════════════════════════════════════════════════════
-- 공지사항 작성 권한 제한 (관리자 전용)
-- 실행 위치: Supabase Dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════
--
-- 목적: 프론트엔드 검증만으로는 REST API 직접 호출로 우회 가능.
--       DB RLS 레이어에서 cat='notice' INSERT를 관리자 이메일만
--       허용하도록 강제.
-- ══════════════════════════════════════════════════════════

-- 1) posts 테이블 RLS 활성화 (이미 켜져 있어도 무해)
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- 2) 기존 동일명 정책 제거 (재실행 안전성)
DROP POLICY IF EXISTS "Admin only can insert notices" ON posts;
DROP POLICY IF EXISTS "Users can insert non-notice posts" ON posts;

-- 3) 공지 INSERT: 관리자 이메일만 허용
CREATE POLICY "Admin only can insert notices"
ON posts
AS RESTRICTIVE
FOR INSERT
TO authenticated
WITH CHECK (
  cat != 'notice'
  OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
);

-- 4) 공지 UPDATE/DELETE도 관리자 이메일만 — 공지 수정·삭제 보호
DROP POLICY IF EXISTS "Admin only can update notices" ON posts;
CREATE POLICY "Admin only can update notices"
ON posts
AS RESTRICTIVE
FOR UPDATE
TO authenticated
USING (
  cat != 'notice'
  OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
)
WITH CHECK (
  cat != 'notice'
  OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
);

DROP POLICY IF EXISTS "Admin only can delete notices" ON posts;
CREATE POLICY "Admin only can delete notices"
ON posts
AS RESTRICTIVE
FOR DELETE
TO authenticated
USING (
  cat != 'notice'
  OR (auth.jwt() ->> 'email') = 'dlrbgns456@gmail.com'
);

-- ══════════════════════════════════════════════════════════
-- 확인 쿼리 (실행 후 정책이 잘 등록됐는지 검증)
-- ══════════════════════════════════════════════════════════
-- SELECT policyname, cmd, qual, with_check
--   FROM pg_policies
--  WHERE tablename = 'posts'
--    AND policyname LIKE '%notice%';
--
-- 테스트:
-- 1) 일반 유저로 로그인한 상태에서
--      INSERT INTO posts (cat, title, ...) VALUES ('notice', ...)
--    → permission denied / violates row-level security 에러 발생해야 함
-- 2) dlrbgns456@gmail.com 계정으로 같은 INSERT → 성공
