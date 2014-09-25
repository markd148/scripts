require 'fog'


class Vcloud

  def initialize(user,pass,org,url)
    @vcloud = Fog::Compute::VcloudDirector.new(
      :vcloud_director_username => "#{user}@#{org}",
      :vcloud_director_password => pass,
      :vcloud_director_host => url,
      :vcloud_director_show_progress => true, # task progress bar on/off
    )

    @org = @vcloud.organizations.first
  end

  def netexists?(name)
    puts "Checking if network: #{name} exists"
    @org.networks.get_by_name(name)
  end
  
  def process_task(entity)
    if(entity.body[:Tasks][:Task]) then
      id = entity.body[:Tasks][:Task][:href].split('/').last
      puts "Processing task ID #{id}"  
      task = @vcloud.get_task(id).body

      until ['success','error','canceled','aborted'].include?(task[:status])
        puts "Task #{task[:operation]} status: #{task[:status]}"
        task = @vcloud.get_task(id).body
        sleep 5
      end

    end
  end

  def create_vapp(name,vdcname, parentnet, vappnets, bastion_ip)

    body = Nokogiri::XML::Builder.new do |x|
      attrs = {
              'xmlns:ovf' => 'http://schemas.dmtf.org/ovf/envelope/1',
              :xmlns => 'http://www.vmware.com/vcloud/v1.5',
              :name => name
              }
      x.ComposeVAppParams(attrs){
        x.InstantiationParams{
          x.NetworkConfigSection{
            x['ovf'].Info "Info"
vappnets.each do |net|
            x.NetworkConfig(:networkName => net['name']){
              x.Configuration{
                x.IpScopes{
                  x.IpScope{
                    x.IsInherited false
		    x.Gateway net['gateway']
		    x.Netmask '255.255.255.0'
		    x.Dns1 '8.8.8.8'
		    x.Dns2
		    x.DnsSuffix
		    x.IsEnabled true
		    x.AllocatedIpAddresses
		    x.SubAllocations
                  }
                }
		x.ParentNetwork(:href =>  @org.networks.get_by_name(parentnet).href)
                x.FenceMode  "natRouted"
	        x.RetainNetInfoAcrossDeployments false
		x.Features{
		  x.NatService{
		    x.IsEnabled false
		  }
		  x.FirewallService{
	net['rules'].each do |rule|
		    x.FirewallRule{
		      x.Id rule['name']
		      x.IsEnabled true
		      x.Policy 'allow'
		      x.Protocols{
			x.Other 'TCP'
		      }
		      x.IcmpSubType
		      x.Port rule['port']
		      x.DestinationIp 'internal'
		      x.SourcePort -1
		      x.SourceIp rule['source']
		    }
	end
                    x.FirewallRule{
                      x.Id 'SSH'
                      x.IsEnabled true
                      x.Policy 'allow'
                      x.Protocols{
                        x.Other 'TCP'
                      }
                      x.IcmpSubType
                      x.Port 22
                      x.DestinationIp 'internal'
                      x.SourcePort -1
                      x.SourceIp bastion_ip
                    }
		  }
		}
		x.SyslogServerSettings
		x.RouterInfo{
		  x.ExternalIp '10.0.1.101'
		}
              }
            }
end
          }
        }
      }

    end.to_xml

    process_task(@vcloud.request(
            :body    => body,
            :expects => 201,
            :headers => {'Content-Type' => 'application/vnd.vmware.vcloud.composeVAppParams+xml'},
            :method  => 'POST',
            :parser  => Fog::ToHashDocument.new,            
            :path    => "/vdc/#{vdc_id(vdcname)}/action/composeVApp"
    )) 
  end

  def add_vms()
  end

  def configure_edge_gateway()
  end

  def vdc_id(vdcname)
    @org.vdcs.get_by_name(vdcname).id
  end

  def createnet(name,vdc,gateway,mask,dns)
    vdcid = vdc_id(vdc)
    gatewayhref = @vcloud.get_org_vdc_gateways(vdcid).body[:EdgeGatewayRecord].first[:href]
    options = {
      :Configuration => {
        :IpScopes => {
          :IpScope => {
            :IsInherited => false,
            :Gateway => gateway,
            :Netmask => mask,
            :Dns1 => dns
          }
        },
        :FenceMode => 'natRouted'
      },
      :EdgeGateway => {
        :href => gatewayhref
      }
    }
    
    process_task(@vcloud.post_create_org_vdc_network(vdcid, name, options))

  end


  def configurenetwork()
    vapp =  @org.vdcs.first.vapps.get_by_name('template')
    vapp.vms.each do |vm|
      net = vm.network

      options = {
        :ip_address_allocation_mode => 'MANUAL',
	:network_connection_index => "#{net.network_connection_index}",
	:IpAddress => '172.21.0.1',
	:is_connected => 1,
      }      
	puts vapp.id
	puts vapp.href

      @vcloud.put_network_connection_system_section_vapp(vapp.id,options)

    end   
  end

  def deployvm(name,vdc,cat,template,net,ip)
   catalog = @org.catalogs.get_by_name(cat)
   vdcid = @org.vdcs.get_by_name(vdc).id
   networkid = @org.networks.get_by_name(net).id

   options = {
     :vdc_id => vdcid,
     :network_id => networkid,
     :deploy => true,
     :powerOn => false,
   }
   item = catalog.catalog_items.get_by_name(template)
puts item.vapp_template
   #item.instantiate(name,options)
  end


  def poweron(name)
    @vcloud.organizations.first.vdcs.first.vapps.each do |vapp|
      if vapp.name == name then
        response = @vcloud.post_power_on_vapp(vapp.id)
        task = @vcloud.get_task(response[:body][:href].split('/').last)
        puts task[:body]
        puts "Powered On #{name}"
        
      end
    end
  end

  def poweroff(name)
    @vcloud.organizations.first.vdcs.first.vapps.each do |vapp|
      if vapp.name == name then
        response = vapp.power_off
        puts response.body
        puts "powered off #{name}"
      end
    end
  end

def orgbody
    puts @vcloud.organizations.first.body
 
end
end


