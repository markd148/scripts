require 'fog'

  
    @vcloud = Fog::Compute::VcloudDirector.new(
      :vcloud_director_username => "364.14.237096@12-14-14-a67b97",
      :vcloud_director_password => "Agre550$Agre550",
      :vcloud_director_host => "api.vcd.portal.skyscapecloud.com",
      :vcloud_director_show_progress => false, # task progress bar on/off
    )
  
  
     catalog = @vcloud.organizations.first.catalogs[1]
   vdcid = @vcloud.organizations.first.vdcs.first.id
   networkid = @vcloud.organizations.first.networks[2].id

   options = {
     :vdc_id => vdcid,
     :network_id => networkid,
     :deploy => true,
     :powerOn => false,
   }
   catalog.catalog_items[1].instantiate("DEMO_VM",options)