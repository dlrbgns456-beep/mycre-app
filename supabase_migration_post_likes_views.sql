-- ══════════════════════════════════════════════════════════
-- 커뮤니티 카운트 시스템 — 좋아요 / 댓글 / 조회수
-- 실행 위치: Supabase Dashboard → SQL Editor
-- 적용일: 2026-04-29
-- ══════════════════════════════════════════════════════════

-- 1) post_likes 테이블 (사용자별 좋아요 추적, 중복 방지)
CREATE TABLE IF NOT EXISTS post_likes (
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (post_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_post_likes_user ON post_likes(user_id);

ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users can read all likes" ON post_likes;
CREATE POLICY "users can read all likes" ON post_likes
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "users can like as themselves" ON post_likes;
CREATE POLICY "users can like as themselves" ON post_likes
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "users can unlike own likes" ON post_likes;
CREATE POLICY "users can unlike own likes" ON post_likes
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- 2) posts.comment_count 컬럼 (댓글 수 캐시)
ALTER TABLE posts ADD COLUMN IF NOT EXISTS comment_count INTEGER DEFAULT 0;

-- 3) 트리거: post_likes 변경 시 posts.likes 자동 갱신
CREATE OR REPLACE FUNCTION sync_post_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET likes = COALESCE(likes,0) + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET likes = GREATEST(0, COALESCE(likes,0) - 1) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS post_likes_count_trigger ON post_likes;
CREATE TRIGGER post_likes_count_trigger AFTER INSERT OR DELETE ON post_likes
FOR EACH ROW EXECUTE FUNCTION sync_post_likes_count();

-- 4) 트리거: comments 변경 시 posts.comment_count 자동 갱신
CREATE OR REPLACE FUNCTION sync_post_comments_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comment_count = COALESCE(comment_count,0) + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comment_count = GREATEST(0, COALESCE(comment_count,0) - 1) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS post_comments_count_trigger ON comments;
CREATE TRIGGER post_comments_count_trigger AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION sync_post_comments_count();

-- 5) 기존 댓글 수 backfill
UPDATE posts p SET comment_count = (
  SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id
);

-- 6) 조회수 증가 RPC (RLS 우회 + atomic)
CREATE OR REPLACE FUNCTION increment_post_views(post_id_param BIGINT)
RETURNS VOID LANGUAGE sql SECURITY DEFINER AS $$
  UPDATE posts SET views = COALESCE(views, 0) + 1 WHERE id = post_id_param;
$$;

-- 7) 좋아요 토글 RPC (있으면 삭제, 없으면 INSERT)
CREATE OR REPLACE FUNCTION toggle_post_like(post_id_param BIGINT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid UUID := auth.uid();
  existing_id BIGINT;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'auth required';
  END IF;
  SELECT 1 INTO existing_id FROM post_likes WHERE post_id = post_id_param AND user_id = uid;
  IF FOUND THEN
    DELETE FROM post_likes WHERE post_id = post_id_param AND user_id = uid;
    RETURN false; -- 좋아요 해제됨
  ELSE
    INSERT INTO post_likes (post_id, user_id) VALUES (post_id_param, uid);
    RETURN true; -- 좋아요 추가됨
  END IF;
END $$;
