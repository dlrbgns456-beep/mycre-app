# Supabase Migrations

이 폴더는 Supabase GitHub Integration이 자동으로 감지하는 마이그레이션 폴더입니다.

## 새 마이그레이션 작성 방법

파일명 형식: `<YYYYMMDDHHmmss>_<short_name>.sql`

예시:
- `20260601090000_add_user_settings.sql`
- `20260601100000_create_notifications_table.sql`

## 워크플로우

1. `supabase/migrations/` 에 새 .sql 파일 작성
2. `git add supabase/migrations/<file>.sql`
3. `git commit -m "feat: <migration description>"`
4. `git push origin master`
5. Supabase가 자동으로 production DB에 적용 ✨

## 이미 적용된 마이그레이션 (참고)

`_legacy/migrations_archive/`에 백업 — 이미 DB의 `supabase_migrations.schema_migrations`에 등록됨.

마지막 적용본: `20260521032204_add_daily_scan_server_validation`
