# Author: Brant Evans <bevans@redhat.com>

class MiqPoliciesImportExport
  class ParsedNonDialogYamlError < StandardError; end

  def export(export_dir)
    raise "Must supply export dir" if export_dir.blank?

    # Export the Policy Profiles
    export_profiles(export_dir)

    # Export the Policies
    export_policies(export_dir)
  end

  def import(import_dir)
    raise "Must supply import dir" if import_dir.blank?

    # Import the Policies
    import_policies(import_dir)

    # Import the Policy Profiles
    import_profiles(import_dir)
  end

private

  def export_policies(export_dir)
    MiqPolicy.all.each do |p|
      puts("Exporting Policy: #{p.description}")

      File.write("#{export_dir}/Policy_#{p.description.gsub('/', '_')}.yaml", p.export_to_yaml)
    end
  end

  def export_profiles(export_dir)
    MiqPolicySet.all.each do |p|
      puts("Exporting Policy Profile: #{p.description}")

      File.write("#{export_dir}/Profile_#{p.description.gsub('/', '_')}.yaml", p.export_to_yaml)
    end
  end

  def import_policies(import_dir)
    Dir.glob("#{import_dir}/Policy_*yaml") do |filename|
      puts("Importing Policy: #{File.basename(filename, '.yaml').gsub(/^Policy_/, '')} ....")

      policies = YAML.load_file(filename)
      policies.each do |p|
        MiqPolicy.import_from_hash(p['MiqPolicy'], {:save=>true})
      end
    end
  end

  def import_profiles(import_dir)
    Dir.glob("#{import_dir}/Profile_*yaml") do |filename|
      puts("Importing Policy Profile: #{File.basename(filename, '.yaml').gsub(/^Profile_/, '')} ....")

      policies = YAML.load_file(filename)
      policies.each do |p|
        MiqPolicySet.import_from_hash(p['MiqPolicySet'], {:save=>true})
      end
    end
  end

end

namespace :rhconsulting do
  namespace :miq_policies do

    desc 'Usage information'
    task :usage => [:environment] do
      puts 'Export - Usage: rake \'rhconsulting:miq_policies:export[/path/to/dir/with/policies]\''
      puts 'Import - Usage: rake \'rhconsulting:miq_policies:import[/path/to/dir/with/policies]\''
    end

    desc 'Exports all policies to individual YAML files'
    task :export, [:filedir] => [:environment] do |_, arguments|
      MiqPoliciesImportExport.new.export(arguments[:filedir])
    end

    desc 'Imports all policies from individual YAML files'
    task :import, [:filedir] => [:environment] do |_, arguments|
      MiqPoliciesImportExport.new.import(arguments[:filedir])
    end

  end
end
