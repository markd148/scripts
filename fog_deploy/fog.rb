require 'fog'


class Deploy

  def initialize(user,pass,org,url)
    @vcloud = Fog::Compute::VcloudDirector.new(
      :vcloud_director_username => "#{user}@#{org}",
      :vcloud_director_password => pass,
      :vcloud_director_host => url,
      :vcloud_director_show_progress => true, # task progress bar on/off
    )
  end



  def deployvm(name)
   catalog = @vcloud.organizations.first.catalogs[1]
   vdcid = @vcloud.organizations.first.vdcs.first.id
   networkid = @vcloud.organizations.first.networks[2].id

   options = {
     :vdc_id => vdcid,
     :network_id => networkid,
     :deploy => true,
     :powerOn => false,
   }
   catalog.catalog_items[1].instantiate(name,options)
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


end


