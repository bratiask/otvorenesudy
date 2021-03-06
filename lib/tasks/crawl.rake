# Usage:
#
# rake crawl:courts
#
# rake crawl:judges
# rake crawl:judge_property_declarations
#
# rake crawl:hearings:civil
# rake crawl:hearings:criminal
# rake crawl:hearings:special
#
# rake crawl:decrees[F]

namespace :crawl do
  desc "Crawl courts from justice.gov.sk"
  task :courts, [:offset, :limit] => :environment do |_, args|
    args.with_defaults safe: false
    JusticeGovSk.crawl_resources Court, args
  end

  desc 'Backup courts data from cache'
  task :'courts:backup' => :environment do
    `mv -f #{Rails.root.join('storage', 'pages', 'courts')} #{Rails.root.join('storage', 'pages', 'courts-backup')}`
  end

  desc "Crawl judges from justice.gov.sk"
  task :judges, [:offset, :limit] => :environment do |_, args|
    args.with_defaults safe: false
    JusticeGovSk.crawl_resources Judge, args
  end

  desc "Crawl judge property declarations from sudnarada.gov.sk"
  task :judge_property_declarations, [:offset, :limit] => :environment do |_, args|
    args.with_defaults safe: false
    SudnaradaGovSk.crawl_resources JudgePropertyDeclaration, args
  end

  namespace :hearings do
    desc "Crawl civil hearings from justice.gov.sk"
    task :civil, [:offset, :limit] => :environment do |_, args|
      args.with_defaults safe: false
      JusticeGovSk.crawl_resources CivilHearing, args
    end

    desc "Crawl criminal hearings from justice.gov.sk"
    task :criminal, [:offset, :limit] => :environment do |_, args|
      args.with_defaults safe: false
      JusticeGovSk.crawl_resources CriminalHearing, args
    end

    desc "Crawl special hearings from justice.gov.sk"
    task :special, [:offset, :limit] => :environment do |_, args|
      args.with_defaults safe: false
      JusticeGovSk.crawl_resources SpecialHearing, args
    end
  end

  desc "Crawl decrees from justice.gov.sk"
  task :decrees, [:decree_form_code, :offset, :limit] => :environment do |_, args|
    args.with_defaults safe: false
    JusticeGovSk.crawl_resources Decree, args
  end

  desc 'Crawl selection procedures'
  task :selection_procedures, [:offset, :limit] => :environment do |_, args|
    args.with_defaults safe: false

    JusticeGovSk.crawl_resources SelectionProcedure, args
  end

  desc "Crawl specific court from justice.gov.sk"
  task :court, [:url] => :environment do |_, args|
    JusticeGovSk.crawl_resource Court, args[:url], safe: true
  end

  desc "Crawl specific judge property declaration from sudnarada.gov.sk"
  task :judge_property_declaration, [:url, :court_name, :judge_name] => :environment do |_, args|
    args.with_defaults safe: true
    SudnaradaGovSk.crawl_resource JudgePropertyDeclaration, args[:url], args
  end

  namespace :hearing do
    desc "Crawl specific civil hearing from justice.gov.sk"
    task :civil, [:url] => :environment do |_, args|
      JusticeGovSk.crawl_resource CivilHearing, args[:url], safe: true
    end

    desc "Crawl specific criminal hearing from justice.gov.sk"
    task :criminal, [:url] => :environment do |_, args|
      JusticeGovSk.crawl_resource CriminalHearing, args[:url], safe: true
    end

    desc "Crawl specific special hearing from justice.gov.sk"
    task :special, [:url] => :environment do |_, args|
      JusticeGovSk.crawl_resource SpecialHearing, args[:url], safe: true
    end
  end

  desc "Crawl specific decree from justice.gov.sk"
  task :decree, [:url, :decree_form_code] => :environment do |_, args|
    args.with_defaults safe: true
    JusticeGovSk.crawl_resource Decree, args[:url], args
  end

  desc 'Crawl specific selection procedure'
  task :selection_procedure, [:url] => :environment do |_, args|
    JusticeGovSk.crawl_resource SelectionProcedure, args[:url], safe: true
  end
end
