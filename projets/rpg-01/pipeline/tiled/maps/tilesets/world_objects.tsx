<?xml version='1.0' encoding='utf-8'?>
<tileset version="1.10" tiledversion="1.12.2" name="world_objects" tilewidth="256" tileheight="219" tilecount="71" columns="0" objectalignment="bottom">
 <properties>
  <property name="godot_source_id" value="20" type="int" />
  <property name="godot_mapping" value="explicit_atlas_coordinates" />
  <property name="description" value="Objets nommés du monde, ancrés par leur point de pied" />
 </properties>
 <tile id="0" class="solid_footprint">
  <properties>
   <property name="object_id" value="boundary.fence_wood_long" />
   <property name="godot_atlas_x" value="0" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Fences" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/boundary" />
   <property name="foot_anchor_x" value="96" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="17" type="int" />
   <property name="content_offset_y" value="33" type="int" />
   <property name="content_width" value="158" type="int" />
   <property name="content_height" value="58" type="int" />
   <property name="tiled_image_width" value="192" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/00_boundary_fence_wood_long.png" width="192" height="91" />
 </tile>
 <tile id="1" class="solid_footprint">
  <properties>
   <property name="object_id" value="boundary.fence_wood_short" />
   <property name="godot_atlas_x" value="18" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Fences" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/boundary" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="13" type="int" />
   <property name="content_offset_y" value="22" type="int" />
   <property name="content_width" value="70" type="int" />
   <property name="content_height" value="69" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/01_boundary_fence_wood_short.png" width="96" height="91" />
 </tile>
 <tile id="2" class="openable_gate">
  <properties>
   <property name="object_id" value="boundary.gate_wood_closed" />
   <property name="godot_atlas_x" value="6" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Fences" />
   <property name="default_role" value="openable_gate" />
   <property name="asset_group" value="architecture/boundary" />
   <property name="foot_anchor_x" value="64" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="27" type="int" />
   <property name="content_width" value="112" type="int" />
   <property name="content_height" value="64" type="int" />
   <property name="tiled_image_width" value="128" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/02_boundary_gate_wood_closed.png" width="128" height="91" />
 </tile>
 <tile id="3" class="solid_footprint">
  <properties>
   <property name="object_id" value="boundary.wall_stone_corner" />
   <property name="godot_atlas_x" value="21" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="WallsBack" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/boundary" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="7" type="int" />
   <property name="content_offset_y" value="22" type="int" />
   <property name="content_width" value="81" type="int" />
   <property name="content_height" value="69" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/03_boundary_wall_stone_corner.png" width="96" height="91" />
 </tile>
 <tile id="4" class="solid_footprint">
  <properties>
   <property name="object_id" value="boundary.wall_stone_long" />
   <property name="godot_atlas_x" value="56" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="WallsBack" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/boundary" />
   <property name="foot_anchor_x" value="112" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="18" type="int" />
   <property name="content_offset_y" value="35" type="int" />
   <property name="content_width" value="187" type="int" />
   <property name="content_height" value="56" type="int" />
   <property name="tiled_image_width" value="224" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/04_boundary_wall_stone_long.png" width="224" height="91" />
 </tile>
 <tile id="5" class="solid_footprint">
  <properties>
   <property name="object_id" value="boundary.wall_stone_medium" />
   <property name="godot_atlas_x" value="10" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="WallsBack" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/boundary" />
   <property name="foot_anchor_x" value="64" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="19" type="int" />
   <property name="content_offset_y" value="35" type="int" />
   <property name="content_width" value="90" type="int" />
   <property name="content_height" value="56" type="int" />
   <property name="tiled_image_width" value="128" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/05_boundary_wall_stone_medium.png" width="128" height="91" />
 </tile>
 <tile id="6" class="visual_only">
  <properties>
   <property name="object_id" value="building.chimney_stone" />
   <property name="godot_atlas_x" value="13" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="WallsFront" />
   <property name="default_role" value="visual_only" />
   <property name="asset_group" value="architecture/building_parts" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="155" type="int" />
   <property name="content_offset_x" value="19" type="int" />
   <property name="content_offset_y" value="35" type="int" />
   <property name="content_width" value="57" type="int" />
   <property name="content_height" value="120" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="155" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/06_building_chimney_stone.png" width="96" height="155" />
 </tile>
 <tile id="7" class="building_with_entrance">
  <properties>
   <property name="object_id" value="building.cottage_exterior" />
   <property name="godot_atlas_x" value="0" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="Buildings" />
   <property name="default_role" value="building_with_entrance" />
   <property name="asset_group" value="architecture/building" />
   <property name="foot_anchor_x" value="112" type="int" />
   <property name="foot_anchor_y" value="219" type="int" />
   <property name="content_offset_x" value="10" type="int" />
   <property name="content_offset_y" value="12" type="int" />
   <property name="content_width" value="203" type="int" />
   <property name="content_height" value="207" type="int" />
   <property name="tiled_image_width" value="224" type="int" />
   <property name="tiled_image_height" value="219" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="mixed" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/07_building_cottage_exterior.png" width="224" height="219" />
 </tile>
 <tile id="8" class="entrance">
  <properties>
   <property name="object_id" value="building.door_stone_arch" />
   <property name="godot_atlas_x" value="24" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Buildings" />
   <property name="default_role" value="entrance" />
   <property name="asset_group" value="architecture/openings" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="14" type="int" />
   <property name="content_offset_y" value="5" type="int" />
   <property name="content_width" value="68" type="int" />
   <property name="content_height" value="86" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/08_building_door_stone_arch.png" width="96" height="91" />
 </tile>
 <tile id="9" class="visual_only">
  <properties>
   <property name="object_id" value="building.roof_blue_gable" />
   <property name="godot_atlas_x" value="7" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="WallsFront" />
   <property name="default_role" value="visual_only" />
   <property name="asset_group" value="architecture/building_parts" />
   <property name="foot_anchor_x" value="96" type="int" />
   <property name="foot_anchor_y" value="155" type="int" />
   <property name="content_offset_x" value="18" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="156" type="int" />
   <property name="content_height" value="142" type="int" />
   <property name="tiled_image_width" value="192" type="int" />
   <property name="tiled_image_height" value="155" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="mixed" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/09_building_roof_blue_gable.png" width="192" height="155" />
 </tile>
 <tile id="10" class="solid_footprint">
  <properties>
   <property name="object_id" value="building.wall_plain_plaster" />
   <property name="godot_atlas_x" value="30" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="Buildings" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/building_parts" />
   <property name="foot_anchor_x" value="80" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="13" type="int" />
   <property name="content_offset_y" value="20" type="int" />
   <property name="content_width" value="134" type="int" />
   <property name="content_height" value="103" type="int" />
   <property name="tiled_image_width" value="160" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="mixed" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/10_building_wall_plain_plaster.png" width="160" height="123" />
 </tile>
 <tile id="11" class="solid_footprint">
  <properties>
   <property name="object_id" value="building.wall_window_plaster" />
   <property name="godot_atlas_x" value="35" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="Buildings" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="architecture/building_parts" />
   <property name="foot_anchor_x" value="80" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="19" type="int" />
   <property name="content_offset_y" value="19" type="int" />
   <property name="content_width" value="121" type="int" />
   <property name="content_height" value="104" type="int" />
   <property name="tiled_image_width" value="160" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="mixed" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/11_building_wall_window_plaster.png" width="160" height="123" />
 </tile>
 <tile id="12" class="visual_only">
  <properties>
   <property name="object_id" value="building.window_wood_blue" />
   <property name="godot_atlas_x" value="27" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Buildings" />
   <property name="default_role" value="visual_only" />
   <property name="asset_group" value="architecture/openings" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="17" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="62" type="int" />
   <property name="content_height" value="57" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/12_building_window_wood_blue.png" width="96" height="91" />
 </tile>
 <tile id="13" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_blue_a" />
   <property name="godot_atlas_x" value="6" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="5" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="53" type="int" />
   <property name="content_height" value="46" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/13_decor_flower_cluster_blue_a.png" width="64" height="59" />
 </tile>
 <tile id="14" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_blue_b" />
   <property name="godot_atlas_x" value="8" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="9" type="int" />
   <property name="content_offset_y" value="18" type="int" />
   <property name="content_width" value="46" type="int" />
   <property name="content_height" value="41" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/14_decor_flower_cluster_blue_b.png" width="64" height="59" />
 </tile>
 <tile id="15" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_pink_a" />
   <property name="godot_atlas_x" value="10" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="7" type="int" />
   <property name="content_offset_y" value="9" type="int" />
   <property name="content_width" value="49" type="int" />
   <property name="content_height" value="50" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/15_decor_flower_cluster_pink_a.png" width="64" height="59" />
 </tile>
 <tile id="16" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_pink_b" />
   <property name="godot_atlas_x" value="12" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="10" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="44" type="int" />
   <property name="content_height" value="46" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/16_decor_flower_cluster_pink_b.png" width="64" height="59" />
 </tile>
 <tile id="17" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_white_a" />
   <property name="godot_atlas_x" value="14" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="46" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/17_decor_flower_cluster_white_a.png" width="64" height="59" />
 </tile>
 <tile id="18" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_white_b" />
   <property name="godot_atlas_x" value="16" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="9" type="int" />
   <property name="content_offset_y" value="14" type="int" />
   <property name="content_width" value="45" type="int" />
   <property name="content_height" value="45" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/18_decor_flower_cluster_white_b.png" width="64" height="59" />
 </tile>
 <tile id="19" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_yellow_a" />
   <property name="godot_atlas_x" value="18" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="14" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="45" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/19_decor_flower_cluster_yellow_a.png" width="64" height="59" />
 </tile>
 <tile id="20" class="decor">
  <properties>
   <property name="object_id" value="decor.flower_cluster_yellow_b" />
   <property name="godot_atlas_x" value="20" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/flowers" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="46" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/20_decor_flower_cluster_yellow_b.png" width="64" height="59" />
 </tile>
 <tile id="21" class="decor">
  <properties>
   <property name="object_id" value="decor.grass_tuft_a" />
   <property name="godot_atlas_x" value="22" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/ground_cover" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="11" type="int" />
   <property name="content_offset_y" value="20" type="int" />
   <property name="content_width" value="42" type="int" />
   <property name="content_height" value="39" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/21_decor_grass_tuft_a.png" width="64" height="59" />
 </tile>
 <tile id="22" class="decor">
  <properties>
   <property name="object_id" value="decor.grass_tuft_b" />
   <property name="godot_atlas_x" value="24" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/ground_cover" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="13" type="int" />
   <property name="content_offset_y" value="23" type="int" />
   <property name="content_width" value="37" type="int" />
   <property name="content_height" value="36" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/22_decor_grass_tuft_b.png" width="64" height="59" />
 </tile>
 <tile id="23" class="decor">
  <properties>
   <property name="object_id" value="decor.grass_tuft_c" />
   <property name="godot_atlas_x" value="26" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/ground_cover" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="10" type="int" />
   <property name="content_offset_y" value="21" type="int" />
   <property name="content_width" value="44" type="int" />
   <property name="content_height" value="38" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/23_decor_grass_tuft_c.png" width="64" height="59" />
 </tile>
 <tile id="24" class="decor">
  <properties>
   <property name="object_id" value="decor.pebble_single" />
   <property name="godot_atlas_x" value="4" type="int" />
   <property name="godot_atlas_y" value="12" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/pebbles" />
   <property name="foot_anchor_x" value="16" type="int" />
   <property name="foot_anchor_y" value="27" type="int" />
   <property name="content_offset_x" value="6" type="int" />
   <property name="content_offset_y" value="11" type="int" />
   <property name="content_width" value="19" type="int" />
   <property name="content_height" value="16" type="int" />
   <property name="tiled_image_width" value="32" type="int" />
   <property name="tiled_image_height" value="27" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/24_decor_pebble_single.png" width="32" height="27" />
 </tile>
 <tile id="25" class="decor">
  <properties>
   <property name="object_id" value="decor.pebbles_cluster_large" />
   <property name="godot_atlas_x" value="28" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/pebbles" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="6" type="int" />
   <property name="content_offset_y" value="19" type="int" />
   <property name="content_width" value="51" type="int" />
   <property name="content_height" value="40" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/25_decor_pebbles_cluster_large.png" width="64" height="59" />
 </tile>
 <tile id="26" class="decor">
  <properties>
   <property name="object_id" value="decor.pebbles_cluster_medium" />
   <property name="godot_atlas_x" value="5" type="int" />
   <property name="godot_atlas_y" value="12" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/pebbles" />
   <property name="foot_anchor_x" value="16" type="int" />
   <property name="foot_anchor_y" value="27" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="16" type="int" />
   <property name="content_height" value="14" type="int" />
   <property name="tiled_image_width" value="32" type="int" />
   <property name="tiled_image_height" value="27" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/26_decor_pebbles_cluster_medium.png" width="32" height="27" />
 </tile>
 <tile id="27" class="decor">
  <properties>
   <property name="object_id" value="decor.pebbles_cluster_small" />
   <property name="godot_atlas_x" value="30" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/pebbles" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="12" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="39" type="int" />
   <property name="content_height" value="25" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/27_decor_pebbles_cluster_small.png" width="64" height="59" />
 </tile>
 <tile id="28" class="decor">
  <properties>
   <property name="object_id" value="decor.sprout_a" />
   <property name="godot_atlas_x" value="2" type="int" />
   <property name="godot_atlas_y" value="12" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/ground_cover" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="27" type="int" />
   <property name="content_offset_x" value="19" type="int" />
   <property name="content_offset_y" value="7" type="int" />
   <property name="content_width" value="25" type="int" />
   <property name="content_height" value="20" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="27" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/28_decor_sprout_a.png" width="64" height="27" />
 </tile>
 <tile id="29" class="decor">
  <properties>
   <property name="object_id" value="decor.sprout_b" />
   <property name="godot_atlas_x" value="32" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="GroundDecor" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/ground_cover" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="17" type="int" />
   <property name="content_offset_y" value="35" type="int" />
   <property name="content_width" value="29" type="int" />
   <property name="content_height" value="24" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/29_decor_sprout_b.png" width="64" height="59" />
 </tile>
 <tile id="30" class="harvestable">
  <properties>
   <property name="object_id" value="farm.crop_cabbages" />
   <property name="godot_atlas_x" value="61" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="harvestable" />
   <property name="asset_group" value="agriculture/crops" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="16" type="int" />
   <property name="content_offset_y" value="8" type="int" />
   <property name="content_width" value="64" type="int" />
   <property name="content_height" value="51" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/30_farm_crop_cabbages.png" width="96" height="59" />
 </tile>
 <tile id="31" class="harvestable">
  <properties>
   <property name="object_id" value="farm.crop_carrots_a" />
   <property name="godot_atlas_x" value="34" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="harvestable" />
   <property name="asset_group" value="agriculture/crops" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="9" type="int" />
   <property name="content_offset_y" value="7" type="int" />
   <property name="content_width" value="46" type="int" />
   <property name="content_height" value="52" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/31_farm_crop_carrots_a.png" width="64" height="59" />
 </tile>
 <tile id="32" class="harvestable">
  <properties>
   <property name="object_id" value="farm.crop_carrots_b" />
   <property name="godot_atlas_x" value="36" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="harvestable" />
   <property name="asset_group" value="agriculture/crops" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="9" type="int" />
   <property name="content_offset_y" value="8" type="int" />
   <property name="content_width" value="45" type="int" />
   <property name="content_height" value="51" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/32_farm_crop_carrots_b.png" width="64" height="59" />
 </tile>
 <tile id="33" class="harvestable">
  <properties>
   <property name="object_id" value="farm.crop_sprouts_a" />
   <property name="godot_atlas_x" value="38" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="harvestable" />
   <property name="asset_group" value="agriculture/crops" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="11" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="48" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/33_farm_crop_sprouts_a.png" width="64" height="59" />
 </tile>
 <tile id="34" class="harvestable">
  <properties>
   <property name="object_id" value="farm.crop_sprouts_b" />
   <property name="godot_atlas_x" value="40" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="harvestable" />
   <property name="asset_group" value="agriculture/crops" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="11" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="48" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/34_farm_crop_sprouts_b.png" width="64" height="59" />
 </tile>
 <tile id="35" class="farm_plot">
  <properties>
   <property name="object_id" value="farm.soil_plot_empty" />
   <property name="godot_atlas_x" value="42" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="CultivatedSoil" />
   <property name="default_role" value="farm_plot" />
   <property name="asset_group" value="agriculture/plots" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="11" type="int" />
   <property name="content_width" value="47" type="int" />
   <property name="content_height" value="48" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/35_farm_soil_plot_empty.png" width="64" height="59" />
 </tile>
 <tile id="36" class="solid_footprint">
  <properties>
   <property name="object_id" value="obstacle.boulder_cluster_large" />
   <property name="godot_atlas_x" value="40" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/rocks" />
   <property name="foot_anchor_x" value="64" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="29" type="int" />
   <property name="content_width" value="111" type="int" />
   <property name="content_height" value="94" type="int" />
   <property name="tiled_image_width" value="128" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="3" type="int" />
  </properties>
  <image source="objects/world_objects/36_obstacle_boulder_cluster_large.png" width="128" height="123" />
 </tile>
 <tile id="37" class="solid_footprint">
  <properties>
   <property name="object_id" value="obstacle.boulder_cluster_medium" />
   <property name="godot_atlas_x" value="30" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/rocks" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="14" type="int" />
   <property name="content_offset_y" value="31" type="int" />
   <property name="content_width" value="68" type="int" />
   <property name="content_height" value="60" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="3" type="int" />
  </properties>
  <image source="objects/world_objects/37_obstacle_boulder_cluster_medium.png" width="96" height="91" />
 </tile>
 <tile id="38" class="small_obstacle">
  <properties>
   <property name="object_id" value="obstacle.rock_small" />
   <property name="godot_atlas_x" value="44" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="small_obstacle" />
   <property name="asset_group" value="nature/rocks" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="10" type="int" />
   <property name="content_offset_y" value="24" type="int" />
   <property name="content_width" value="43" type="int" />
   <property name="content_height" value="35" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="1" type="int" />
  </properties>
  <image source="objects/world_objects/38_obstacle_rock_small.png" width="64" height="59" />
 </tile>
 <tile id="39" class="small_obstacle">
  <properties>
   <property name="object_id" value="prop.barrel_water" />
   <property name="godot_atlas_x" value="45" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="small_obstacle" />
   <property name="asset_group" value="props/storage" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="29" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="62" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="1" type="int" />
  </properties>
  <image source="objects/world_objects/39_prop_barrel_water.png" width="64" height="91" />
 </tile>
 <tile id="40" class="small_obstacle">
  <properties>
   <property name="object_id" value="prop.crate_wood_large" />
   <property name="godot_atlas_x" value="47" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="small_obstacle" />
   <property name="asset_group" value="props/storage" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="7" type="int" />
   <property name="content_offset_y" value="28" type="int" />
   <property name="content_width" value="50" type="int" />
   <property name="content_height" value="63" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="1" type="int" />
  </properties>
  <image source="objects/world_objects/40_prop_crate_wood_large.png" width="64" height="91" />
 </tile>
 <tile id="41" class="solid_footprint">
  <properties>
   <property name="object_id" value="prop.fallen_logs" />
   <property name="godot_atlas_x" value="14" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/wood" />
   <property name="foot_anchor_x" value="64" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="14" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="99" type="int" />
   <property name="content_height" value="57" type="int" />
   <property name="tiled_image_width" value="128" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="1" type="int" />
  </properties>
  <image source="objects/world_objects/41_prop_fallen_logs.png" width="128" height="91" />
 </tile>
 <tile id="42" class="soft_obstacle">
  <properties>
   <property name="object_id" value="prop.haystack_round" />
   <property name="godot_atlas_x" value="33" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="soft_obstacle" />
   <property name="asset_group" value="props/agriculture" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="13" type="int" />
   <property name="content_offset_y" value="26" type="int" />
   <property name="content_width" value="70" type="int" />
   <property name="content_height" value="65" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="mixed" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/42_prop_haystack_round.png" width="96" height="91" />
 </tile>
 <tile id="43" class="small_obstacle">
  <properties>
   <property name="object_id" value="prop.planter_flowers" />
   <property name="godot_atlas_x" value="36" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="small_obstacle" />
   <property name="asset_group" value="props/garden" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="12" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="71" type="int" />
   <property name="content_height" value="57" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="mixed" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/43_prop_planter_flowers.png" width="96" height="91" />
 </tile>
 <tile id="44" class="interactable">
  <properties>
   <property name="object_id" value="prop.signpost_wood" />
   <property name="godot_atlas_x" value="49" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="interactable" />
   <property name="asset_group" value="props/information" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="6" type="int" />
   <property name="content_offset_y" value="18" type="int" />
   <property name="content_width" value="51" type="int" />
   <property name="content_height" value="73" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/44_prop_signpost_wood.png" width="64" height="91" />
 </tile>
 <tile id="45" class="small_obstacle">
  <properties>
   <property name="object_id" value="prop.tree_stump" />
   <property name="godot_atlas_x" value="0" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="small_obstacle" />
   <property name="asset_group" value="nature/wood" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="17" type="int" />
   <property name="content_offset_y" value="8" type="int" />
   <property name="content_width" value="62" type="int" />
   <property name="content_height" value="51" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="movable" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="true" type="bool" />
   <property name="psychokinesis_required_power" value="1" type="int" />
  </properties>
  <image source="objects/world_objects/45_prop_tree_stump.png" width="96" height="59" />
 </tile>
 <tile id="46" class="solid_interactable">
  <properties>
   <property name="object_id" value="prop.well_stone_round" />
   <property name="godot_atlas_x" value="39" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="solid_interactable" />
   <property name="asset_group" value="props/utility" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="17" type="int" />
   <property name="content_offset_y" value="12" type="int" />
   <property name="content_width" value="62" type="int" />
   <property name="content_height" value="79" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="medium" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/46_prop_well_stone_round.png" width="96" height="91" />
 </tile>
 <tile id="47" class="solid_footprint">
  <properties>
   <property name="object_id" value="relief.cliff_pillar_medium" />
   <property name="godot_atlas_x" value="51" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="CliffFaces" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/relief" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="6" type="int" />
   <property name="content_offset_y" value="28" type="int" />
   <property name="content_width" value="52" type="int" />
   <property name="content_height" value="63" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/47_relief_cliff_pillar_medium.png" width="64" height="91" />
 </tile>
 <tile id="48" class="solid_footprint">
  <properties>
   <property name="object_id" value="relief.cliff_pillar_small" />
   <property name="godot_atlas_x" value="46" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="CliffFaces" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/relief" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="11" type="int" />
   <property name="content_width" value="47" type="int" />
   <property name="content_height" value="48" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/48_relief_cliff_pillar_small.png" width="64" height="59" />
 </tile>
 <tile id="49" class="solid_footprint">
  <properties>
   <property name="object_id" value="relief.cliff_pillar_tall" />
   <property name="godot_atlas_x" value="44" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="CliffFaces" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/relief" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="14" type="int" />
   <property name="content_offset_y" value="32" type="int" />
   <property name="content_width" value="67" type="int" />
   <property name="content_height" value="91" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/49_relief_cliff_pillar_tall.png" width="96" height="123" />
 </tile>
 <tile id="50" class="solid_footprint">
  <properties>
   <property name="object_id" value="relief.cliff_pillar_tiny" />
   <property name="godot_atlas_x" value="48" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="CliffFaces" />
   <property name="default_role" value="solid_footprint" />
   <property name="asset_group" value="nature/relief" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="18" type="int" />
   <property name="content_offset_y" value="12" type="int" />
   <property name="content_width" value="28" type="int" />
   <property name="content_height" value="47" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/50_relief_cliff_pillar_tiny.png" width="64" height="59" />
 </tile>
 <tile id="51" class="bridge_deck_with_blocked_sides">
  <properties>
   <property name="object_id" value="traversal.bridge_wood_stone_long" />
   <property name="godot_atlas_x" value="22" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="Bridges" />
   <property name="default_role" value="bridge_deck_with_blocked_sides" />
   <property name="asset_group" value="architecture/traversal" />
   <property name="foot_anchor_x" value="128" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="9" type="int" />
   <property name="content_offset_y" value="19" type="int" />
   <property name="content_width" value="237" type="int" />
   <property name="content_height" value="104" type="int" />
   <property name="tiled_image_width" value="256" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/51_traversal_bridge_wood_stone_long.png" width="256" height="123" />
 </tile>
 <tile id="52" class="elevation_transition">
  <properties>
   <property name="object_id" value="traversal.stairs_stone_north" />
   <property name="godot_atlas_x" value="47" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="Stairs" />
   <property name="default_role" value="elevation_transition" />
   <property name="asset_group" value="architecture/traversal" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="7" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="82" type="int" />
   <property name="content_height" value="110" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="anchored" />
   <property name="psychokinesis_mass" value="immense" />
   <property name="psychokinesis_material" value="stone" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/52_traversal_stairs_stone_north.png" width="96" height="123" />
 </tile>
 <tile id="53" class="decor">
  <properties>
   <property name="object_id" value="vegetation.bush_round_a" />
   <property name="godot_atlas_x" value="42" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/bushes" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="19" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="58" type="int" />
   <property name="content_height" value="57" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/53_vegetation_bush_round_a.png" width="96" height="91" />
 </tile>
 <tile id="54" class="decor">
  <properties>
   <property name="object_id" value="vegetation.bush_round_b" />
   <property name="godot_atlas_x" value="3" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/bushes" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="20" type="int" />
   <property name="content_offset_y" value="5" type="int" />
   <property name="content_width" value="56" type="int" />
   <property name="content_height" value="54" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/54_vegetation_bush_round_b.png" width="96" height="59" />
 </tile>
 <tile id="55" class="decor">
  <properties>
   <property name="object_id" value="vegetation.bush_round_c" />
   <property name="godot_atlas_x" value="50" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/bushes" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="5" type="int" />
   <property name="content_offset_y" value="5" type="int" />
   <property name="content_width" value="54" type="int" />
   <property name="content_height" value="54" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/55_vegetation_bush_round_c.png" width="64" height="59" />
 </tile>
 <tile id="56" class="decor">
  <properties>
   <property name="object_id" value="vegetation.bush_round_d" />
   <property name="godot_atlas_x" value="52" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/bushes" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="5" type="int" />
   <property name="content_offset_y" value="5" type="int" />
   <property name="content_width" value="54" type="int" />
   <property name="content_height" value="54" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/56_vegetation_bush_round_d.png" width="64" height="59" />
 </tile>
 <tile id="57" class="tree_trunk_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_large" />
   <property name="godot_atlas_x" value="16" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="tree_trunk_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="155" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="27" type="int" />
   <property name="content_width" value="79" type="int" />
   <property name="content_height" value="128" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="155" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/57_vegetation_tree_pine_large.png" width="96" height="155" />
 </tile>
 <tile id="58" class="tree_trunk_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_medium_a" />
   <property name="godot_atlas_x" value="50" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="tree_trunk_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="13" type="int" />
   <property name="content_offset_y" value="15" type="int" />
   <property name="content_width" value="69" type="int" />
   <property name="content_height" value="108" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/58_vegetation_tree_pine_medium_a.png" width="96" height="123" />
 </tile>
 <tile id="59" class="tree_trunk_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_medium_b" />
   <property name="godot_atlas_x" value="53" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="tree_trunk_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="123" type="int" />
   <property name="content_offset_x" value="19" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="57" type="int" />
   <property name="content_height" value="89" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="123" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/59_vegetation_tree_pine_medium_b.png" width="96" height="123" />
 </tile>
 <tile id="60" class="soft_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_sapling" />
   <property name="godot_atlas_x" value="54" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="Vegetation" />
   <property name="default_role" value="soft_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="14" type="int" />
   <property name="content_offset_y" value="5" type="int" />
   <property name="content_width" value="35" type="int" />
   <property name="content_height" value="54" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/60_vegetation_tree_pine_sapling.png" width="64" height="59" />
 </tile>
 <tile id="61" class="tree_trunk_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_small_a" />
   <property name="godot_atlas_x" value="53" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="tree_trunk_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="13" type="int" />
   <property name="content_width" value="48" type="int" />
   <property name="content_height" value="78" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/61_vegetation_tree_pine_small_a.png" width="64" height="91" />
 </tile>
 <tile id="62" class="tree_trunk_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_small_b" />
   <property name="godot_atlas_x" value="55" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="tree_trunk_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="10" type="int" />
   <property name="content_offset_y" value="23" type="int" />
   <property name="content_width" value="43" type="int" />
   <property name="content_height" value="68" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/62_vegetation_tree_pine_small_b.png" width="64" height="91" />
 </tile>
 <tile id="63" class="tree_trunk_obstacle">
  <properties>
   <property name="object_id" value="vegetation.tree_pine_xl" />
   <property name="godot_atlas_x" value="19" type="int" />
   <property name="godot_atlas_y" value="0" type="int" />
   <property name="recommended_layer" value="YSortedProps" />
   <property name="default_role" value="tree_trunk_obstacle" />
   <property name="asset_group" value="nature/trees" />
   <property name="foot_anchor_x" value="48" type="int" />
   <property name="foot_anchor_y" value="155" type="int" />
   <property name="content_offset_x" value="6" type="int" />
   <property name="content_offset_y" value="19" type="int" />
   <property name="content_width" value="83" type="int" />
   <property name="content_height" value="136" type="int" />
   <property name="tiled_image_width" value="96" type="int" />
   <property name="tiled_image_height" value="155" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="heavy" />
   <property name="psychokinesis_material" value="wood" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/63_vegetation_tree_pine_xl.png" width="96" height="155" />
 </tile>
 <tile id="64" class="decor">
  <properties>
   <property name="object_id" value="water.cattails_cluster_a" />
   <property name="godot_atlas_x" value="57" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="9" type="int" />
   <property name="content_offset_y" value="11" type="int" />
   <property name="content_width" value="46" type="int" />
   <property name="content_height" value="80" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/64_water_cattails_cluster_a.png" width="64" height="91" />
 </tile>
 <tile id="65" class="decor">
  <properties>
   <property name="object_id" value="water.cattails_cluster_b" />
   <property name="godot_atlas_x" value="59" type="int" />
   <property name="godot_atlas_y" value="7" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="91" type="int" />
   <property name="content_offset_x" value="10" type="int" />
   <property name="content_offset_y" value="23" type="int" />
   <property name="content_width" value="44" type="int" />
   <property name="content_height" value="68" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="91" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/65_water_cattails_cluster_b.png" width="64" height="91" />
 </tile>
 <tile id="66" class="decor">
  <properties>
   <property name="object_id" value="water.lily_pad_large" />
   <property name="godot_atlas_x" value="56" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="13" type="int" />
   <property name="content_offset_y" value="29" type="int" />
   <property name="content_width" value="38" type="int" />
   <property name="content_height" value="30" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/66_water_lily_pad_large.png" width="64" height="59" />
 </tile>
 <tile id="67" class="decor">
  <properties>
   <property name="object_id" value="water.lily_pad_medium" />
   <property name="godot_atlas_x" value="58" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="16" type="int" />
   <property name="content_offset_y" value="34" type="int" />
   <property name="content_width" value="32" type="int" />
   <property name="content_height" value="25" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/67_water_lily_pad_medium.png" width="64" height="59" />
 </tile>
 <tile id="68" class="decor">
  <properties>
   <property name="object_id" value="water.lily_pad_small" />
   <property name="godot_atlas_x" value="60" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="17" type="int" />
   <property name="content_offset_y" value="35" type="int" />
   <property name="content_width" value="30" type="int" />
   <property name="content_height" value="24" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/68_water_lily_pad_small.png" width="64" height="59" />
 </tile>
 <tile id="69" class="decor">
  <properties>
   <property name="object_id" value="water.lotus_pink" />
   <property name="godot_atlas_x" value="62" type="int" />
   <property name="godot_atlas_y" value="10" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="8" type="int" />
   <property name="content_offset_y" value="21" type="int" />
   <property name="content_width" value="47" type="int" />
   <property name="content_height" value="38" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/69_water_lotus_pink.png" width="64" height="59" />
 </tile>
 <tile id="70" class="decor">
  <properties>
   <property name="object_id" value="water.lotus_white" />
   <property name="godot_atlas_x" value="0" type="int" />
   <property name="godot_atlas_y" value="12" type="int" />
   <property name="recommended_layer" value="WaterEffects" />
   <property name="default_role" value="decor" />
   <property name="asset_group" value="nature/water_plants" />
   <property name="foot_anchor_x" value="32" type="int" />
   <property name="foot_anchor_y" value="59" type="int" />
   <property name="content_offset_x" value="7" type="int" />
   <property name="content_offset_y" value="19" type="int" />
   <property name="content_width" value="49" type="int" />
   <property name="content_height" value="40" type="int" />
   <property name="tiled_image_width" value="64" type="int" />
   <property name="tiled_image_height" value="59" type="int" />
   <property name="psychokinesis_response" value="reactive" />
   <property name="psychokinesis_mass" value="light" />
   <property name="psychokinesis_material" value="plant" />
   <property name="psychokinesis_breakable" value="false" type="bool" />
   <property name="psychokinesis_required_power" value="0" type="int" />
  </properties>
  <image source="objects/world_objects/70_water_lotus_white.png" width="64" height="59" />
 </tile>
</tileset>