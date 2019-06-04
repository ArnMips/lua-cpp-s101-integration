-- Converter Version: 0.99
-- Feature Catalogue Version: 1.0.0 (2018/9/6)

-- Referenced portrayal rules.
require 'RESTRN01'

-- Dumping ground main entry point.
function DumpingGround(feature, featurePortrayal, contextParameters)
	if feature.PrimitiveType == PrimitiveType.Point then
		-- Simplified and paper chart points use the same symbolization
		if contextParameters.RADAR_OVERLAY then
			featurePortrayal:AddInstructions('ViewingGroup:26240;DrawingPriority:4;DisplayPlane:OverRADAR')
		else
			featurePortrayal:AddInstructions('ViewingGroup:26240;DrawingPriority:4;DisplayPlane:UnderRADAR')
		end
		featurePortrayal:AddInstructions('PointInstruction:CHINFO07')
	elseif feature.PrimitiveType == PrimitiveType.Surface and contextParameters.PLAIN_BOUNDARIES then
		featurePortrayal:AddInstructions('ViewingGroup:26240;DrawingPriority:3;DisplayPlane:UnderRADAR')
		featurePortrayal:AddInstructions('PointInstruction:INFARE51')
		featurePortrayal:SimpleLineStyle('dash',0.32,'CHMGD')
		featurePortrayal:AddInstructions('LineInstruction:')
		RESTRN01(feature, featurePortrayal, contextParameters)
	elseif feature.PrimitiveType == PrimitiveType.Surface then
		featurePortrayal:AddInstructions('ViewingGroup:26240;DrawingPriority:3;DisplayPlane:UnderRADAR')
		featurePortrayal:AddInstructions('PointInstruction:INFARE51')
		featurePortrayal:AddInstructions('LineInstruction:CTYARE51')
		RESTRN01(feature, featurePortrayal, contextParameters)
	else
		error('Invalid primitive type or mariner settings passed to portrayal')
	end
end
