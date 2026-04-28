-- ══════════════════════════════════════════════════════════
-- geckos.stage 컬럼 추가 (성장 단계 자동 분류)
-- 실행 위치: Supabase Dashboard → SQL Editor
-- 적용일: 2026-04-28
-- ══════════════════════════════════════════════════════════
--
-- 분류 기준 (확정):
--   · 베이비   (~10g)
--   · 아성체   (10~34g)
--   · 성체     (35g+)
--
-- 클라이언트(updateCageAndBreeding)도 동일 임계값 사용.
-- ══════════════════════════════════════════════════════════

ALTER TABLE geckos
  ADD COLUMN IF NOT EXISTS stage TEXT DEFAULT '베이비'
  CHECK (stage IS NULL OR stage IN ('베이비','아성체','성체'));

-- 기존 개체 weight 기반 일괄 분류
UPDATE geckos
  SET stage = CASE
    WHEN weight IS NULL OR weight = '' THEN '베이비'
    WHEN (weight)::NUMERIC < 10 THEN '베이비'
    WHEN (weight)::NUMERIC < 35 THEN '아성체'
    ELSE '성체'
  END;

-- 확인
-- SELECT stage, COUNT(*) FROM geckos GROUP BY stage ORDER BY stage;
