require 'yaml'
require_relative 'fog.rb'

class Deploy
  def initialize(config, vcdconfig)
    @config = YAML.load(File.open(config))
    @vcdconfig = vcdconfig

  end

  def deploy()


    @vcd = Vcloud.new(@vcdconfig[:user],@vcdconfig[:pass],@vcdconfig[:org],@vcdconfig[:url])
    backbone = @config['vapp']['backbone']
    vdcname = @config['vapp']['vdc']
    unless @vcd.netexists?(backbone['name'])
      puts 'Creating Backbone Network'
      @vcd.createnet(backbone['name'], vdcname, backbone['gateway'], backbone['mask'], backbone['dns'])
    else
      puts 'Backbone Net Found'
    end

    puts 'Creating vApp & Networks'
    @vcd.create_vapp(@config['vapp']['name'], vdcname, backbone['name'],@config['vapp']['vms'], @config['vapp']['bastion_ip'])


   #puts 'Configuring Edge Gateway Rules/Routes'
   #@vcd.configure_edge_gateway(@config['vapp']['vms'])

  end

end
