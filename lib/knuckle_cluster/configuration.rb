class KnuckleCluster::Configuration
  require 'yaml'
  DEFAULT_PROFILE_FILE = File.join(ENV['HOME'],'.ssh/knuckle_cluster').freeze

  def self.load_parameters(profile:, profile_file: nil)
    profile_file ||= DEFAULT_PROFILE_FILE
    raise "File #{profile_file} not found" unless File.exists?(profile_file)

    data = YAML.load_file(profile_file)

    unless data.keys.include?(profile)
      raise "Config file does not include profile for #{profile}"
    end

    #Figure out all the profiles to inherit from
    tmp_data = data[profile]
    profile_inheritance = [profile]
    while(tmp_data && tmp_data.keys.include?('profile'))
      profile_name = tmp_data['profile']
      break if profile_inheritance.include? profile_name
      profile_inheritance << profile_name
      tmp_data = data[profile_name]
    end

    #Starting at the very lowest profile, build an options hash
    output = {}
    profile_inheritance.reverse.each do |prof|
      output.merge!(data[prof] || {})
    end

    output.delete('profile')

    keys_to_symbols(output)
  end

  private
  def self.load_profile(data:, profile_name:)

  end

  def self.keys_to_symbols(data)
    #Implemented here - beats including activesupport
    return data unless Hash === data
    ret = {}
    data.each do |k,v|
      if Hash === v
        #Look, doesnt need to be recursive but WHY NOT?!?
        ret[k.to_sym] = keys_to_symbols(v)
      else
        ret[k.to_sym] = v
      end
    end
    ret
  end
end