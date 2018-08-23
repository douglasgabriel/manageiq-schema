require_migration

describe MoveLocationLedStateToAssetDetailsTable do
  let(:physical_server_stub)  { migration_stub(:PhysicalServer) }
  let(:physical_chassis_stub) { migration_stub(:PhysicalChassis) }
  let(:asset_detail_stub)     { migration_stub(:AssetDetail) }

  context "resources with asset detail" do
    migration_context :up do
      it "should migrate the data from physical_chassis and physical_servers to asset_details table" do
        asset_detail_server = asset_detail_stub.create!
        physical_server_stub.create!(
          :asset_detail       => asset_detail_server,
          :location_led_state => 'Off'
        )

        asset_detail_chassis = asset_detail_stub.create!
        physical_chassis_stub.create!(
          :asset_detail       => asset_detail_chassis,
          :location_led_state => 'Blinking'
        )

        migrate

        expect(asset_detail_server.reload.location_led_state).to  eq('Off')
        expect(asset_detail_chassis.reload.location_led_state).to eq('Blinking')
      end
    end

    migration_context :down do
      it "should migrate the data back from asset_details to physical_chassis and physical_servers tables" do
        asset_detail_server = asset_detail_stub.create!(
          :location_led_state => 'Off'
        )
        server = physical_server_stub.create!(
          :asset_detail => asset_detail_server
        )

        asset_detail_chassis = asset_detail_stub.create!(
          :location_led_state => 'Blinking'
        )
        chassis = physical_chassis_stub.create!(
          :asset_detail => asset_detail_chassis
        )

        migrate

        expect(server.reload.location_led_state).to  eq('Off')
        expect(chassis.reload.location_led_state).to eq('Blinking')
      end
    end
  end

  context "resources without asset detail" do
    migration_context :up do
      it "should migrate the data from physical_chassis and physical_servers to asset_details table" do
        server = physical_server_stub.create!(
          :location_led_state => 'Off'
        )

        chassis = physical_chassis_stub.create!(
          :location_led_state => 'Blinking'
        )

        migrate

        expect(server.reload.asset_detail.location_led_state).to  eq('Off')
        expect(chassis.reload.asset_detail.location_led_state).to eq('Blinking')
      end
    end

    migration_context :down do
      it "should migrate the data back from asset_details to physical_chassis and physical_servers tables" do
        server = physical_server_stub.create!

        chassis = physical_chassis_stub.create!

        migrate

        expect(server.reload.location_led_state).to  be_nil
        expect(chassis.reload.location_led_state).to be_nil
      end
    end
  end
end
