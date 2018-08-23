class MoveLocationLedStateToAssetDetailsTable < ActiveRecord::Migration[5.0]
  class AssetDetail < ActiveRecord::Base
    belongs_to :resource, :polymorphic => true

    serialize :location_led_state
  end

  class PhysicalServer < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    has_one :asset_detail, :as => :resource, :dependent => :destroy
  end

  class PhysicalChassis < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    has_one :asset_detail, :as => :resource, :dependent => :destroy
  end

  def up
    add_column :asset_details, :location_led_state, :string

    PhysicalServer.includes(:asset_detail).each do |server|
      server.asset_detail ||= server.build_asset_detail
      server.asset_detail.update_attributes!(:location_led_state => server.location_led_state)
    end

    PhysicalChassis.all.each do |chassis|
      chassis.asset_detail ||= chassis.build_asset_detail
      chassis.asset_detail.update_attributes!(:location_led_state => chassis.location_led_state)
    end

    remove_column :physical_servers, :location_led_state
    remove_column :physical_chassis, :location_led_state
  end

  def down
    add_column :physical_servers, :location_led_state, :string
    add_column :physical_chassis, :location_led_state, :string

    PhysicalServer.all.each do |server|
      server.update_attributes!(:location_led_state => server.asset_detail&.location_led_state)
    end

    PhysicalChassis.all.each do |chassis|
      chassis.update_attributes!(:location_led_state => chassis.asset_detail&.location_led_state)
    end

    remove_column :asset_details, :location_led_state
  end
end
