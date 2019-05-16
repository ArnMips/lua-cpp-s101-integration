-- Converter Version: 0.99
-- Feature Catalogue Version: 1.0.0 (2018/9/6)

-- Deep Water Route Centreline main entry point.
function DeepWaterRouteCentreline(feature, featurePortrayal, contextParameters)
	if feature.PrimitiveType == PrimitiveType.Curve then
		if feature.categoryOfRecommendedTrack == 1 and feature.trafficFlow == 1 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL08')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 1 and feature.trafficFlow == 2 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL08')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 1 and feature.trafficFlow == 3 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL08')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 1 and feature.trafficFlow == 4 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL06')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 2 and feature.trafficFlow == 1 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL07')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 2 and feature.trafficFlow == 2 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL07')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 2 and feature.trafficFlow == 3 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL07')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.categoryOfRecommendedTrack == 2 and feature.trafficFlow == 4 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL05')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.trafficFlow == 1 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL07')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.trafficFlow == 2 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL07')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.trafficFlow == 3 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL07')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		elseif feature.trafficFlow == 4 then
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWRTCL05')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		else
			if contextParameters.RADAR_OVERLAY then
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:OverRADAR')
			else
				featurePortrayal:AddInstructions('ViewingGroup:25010;DrawingPriority:6;DisplayPlane:UnderRADAR')
			end
			featurePortrayal:AddInstructions('LineInstruction:DWLDEF01')
			featurePortrayal:AddInstructions('LocalOffset:0,3.51;TextAlignHorizontal:Center;FontSize:10;TextInstruction:' .. EncodeString(feature.orientationValue, '%03.0f deg') .. ',11,8')
		end
	else
		error('Invalid primitive type or mariner settings passed to portrayal')
	end
end
