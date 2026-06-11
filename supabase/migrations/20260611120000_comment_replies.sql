-- ============================================================
-- 커뮤니티 댓글 대댓글(리댓) 기능 (2026-06-11)
--  comments.parent_id 추가 — 부모 댓글 참조, 부모 삭제 시 대댓글 자동 삭제
--  ※ 멱등(idempotent)
-- ============================================================
ALTER TABLE public.comments
  ADD COLUMN IF NOT EXISTS parent_id bigint REFERENCES public.comments(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_comments_parent ON public.comments(parent_id);
