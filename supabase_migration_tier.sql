-- ══════════════════════════════════════════════════════════
-- 마이크레 멤버십 티어 시스템 마이그레이션
-- 실행 위치: Supabase Dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════

-- 1) profiles 테이블에 tier 컬럼 추가
--    free  : 무료 (기본값)
--    lite  : 일반 (월 1,900원 / 연 19,000원)
--    breeder : 브리더 (월 4,900원 / 연 46,800원)
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS tier TEXT DEFAULT 'free'
  CHECK (tier IN ('free', 'lite', 'breeder'));

-- 2) 기존 PRO 사용자는 breeder로 자동 이관
UPDATE profiles
  SET tier = 'breeder'
  WHERE is_pro = true
    AND (pro_until IS NULL OR pro_until > NOW())
    AND (tier IS NULL OR tier = 'free');

-- 3) payments 테이블에도 tier 컬럼 추가 (결제 내역별 등급 추적)
ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS tier TEXT DEFAULT 'breeder'
  CHECK (tier IN ('lite', 'breeder'));

-- 4) 인덱스 (티어별 통계 조회용)
CREATE INDEX IF NOT EXISTS idx_profiles_tier ON profiles(tier);
CREATE INDEX IF NOT EXISTS idx_payments_tier ON payments(tier);

-- 확인 쿼리
-- SELECT tier, COUNT(*) FROM profiles GROUP BY tier;
