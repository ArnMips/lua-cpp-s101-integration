--[[
This file contains the global functions that define the Lua portrayal API.
These functions are called by the host program.
--]]

portrayalContext = nil

function PortrayalInitializeContextParameters(contextParameters)
	local t__ = start_function_profiling('PortrayalInitializeContextParameters')
	Debug.StartPerformance('Lua Code - Total')
	CheckType(contextParameters, 'array:ContextParameter', 2)

	Debug.StartPerformance('Lua Code - PortrayalInitializeContextParameters')

	portrayalContext = PortrayalModel.CreatePortrayalContext()

	local pccp = portrayalContext.ContextParameters._underlyingTable

	pccp._parameterTypes = {}

	for _, cp in ipairs(contextParameters) do
		pccp[cp.Name] = cp.DefaultValue
		pccp._parameterTypes[cp.Name] = cp.ParameterType
	end

	Debug.StopPerformance('Lua Code - PortrayalInitializeContextParameters')
	Debug.StopPerformance('Lua Code - Total')
	stop_function_profiling(t__, 'PortrayalInitializeContextParameters')
end

function PortrayalCreateContextParameter(contextParameterName, parameterType, defaultValue)
	local t__ = start_function_profiling('PortrayalCreateContextParameter')
	CheckType(contextParameterName, 'string', 2)
	CheckType(parameterType, 'string', 2)

	if parameterType ~= 'boolean' and parameterType ~= 'integer' and parameterType ~= 'real' and parameterType ~= 'text' and parameterType ~= 'date' then
		error('Invalid parameter type.')
	end
	stop_function_profiling(t__, 'PortrayalCreateContextParameter')
	return { Type = 'ContextParameter', Name = contextParameterName, ParameterType = parameterType, DefaultValue = ConvertEncodedValue(parameterType, defaultValue) }
end

function PortrayalSetContextParameter(contextParameterName, value)
	local t__ = start_function_profiling('PortrayalSetContextParameter')
	Debug.StartPerformance('Lua Code - Total')
	CheckType(contextParameterName, 'string', 2)
	CheckType(value, 'string', 2)

	if not portrayalContext then
		error('Portrayal context not initialized.')
	end

	local pccp = portrayalContext.ContextParameters._underlyingTable

	portrayalContext.ContextParameters[contextParameterName] = ConvertEncodedValue(pccp._parameterTypes[contextParameterName], value)

	Debug.StopPerformance('Lua Code - Total')
	stop_function_profiling(t__, 'PortrayalSetContextParameter')
end

local nilAttribute = {}

local function LookupAttributeValue(container, attributeCode, HostGetSimpleAttribute, HostGetComplexAttributeCount)
	local t__ = start_function_profiling('LookupAttributeValue')
	local attributeMetatable =
	{
		__index = function (container, attributeCode)
			return LookupAttributeValue(container, attributeCode, HostGetSimpleAttribute, HostGetComplexAttributeCount)
		end
	}

	local attributeCode1 = attributeCode

	local nilIfMissing = false

	-- Is this a "nil if missing" attribute?
	if attributeCode:sub(1, 1) == '!' then
		nilIfMissing = true

		attributeCode = attributeCode:sub(2)
	end

	local unknownIfUnknown = false

	-- Is this a "unknown if unknown" attribute?
	if attributeCode:sub(1, 1) == '@' then
		unknownIfUnknown = true

		attributeCode = attributeCode:sub(2)
	end

	local attributePath = {}

	local topContainer = container

	while rawget(topContainer, 'Parent') do
		table.insert(attributePath, 1, topContainer.AttributeCode .. ':' .. topContainer.Index)
			
		topContainer = rawget(topContainer, 'Parent')
	end

	attributePath = table.concat(attributePath, ';')

	local ti = GetTypeInfo()

	local containerTypeInfo

	if container.Type == 'ComplexAttributeValue' then
		containerTypeInfo = GetComplexAttributeTypeInfo(container.AttributeCode)
	elseif container.Type == 'Feature' then
		containerTypeInfo = GetFeatureTypeInfo(container.Code)
	elseif container.Type == 'Information' then
		containerTypeInfo = GetInformationTypeInfo(container.Code)
	else
		error('Not implemented')
	end

	--Debug.Break()

	if not containerTypeInfo.AttributeBindings[attributeCode] then
		if nilIfMissing then
			return nil
		else
			error('Invalid attribute code "' .. attributeCode .. '" specified.', 3)
		end
	end

	local simpleAttributeTypeInfo
	local complexAttributeTypeInfo

	if ti.SimpleAttributeInfos[attributeCode] then
		simpleAttributeTypeInfo = GetSimpleAttributeTypeInfo(attributeCode)
	else
		complexAttributeTypeInfo = GetComplexAttributeTypeInfo(attributeCode)
	end

	if complexAttributeTypeInfo then
		Debug.StopPerformance('Lua Code - Total')
		local attributeCount = HostGetComplexAttributeCount(container.ID, attributePath, attributeCode)
		Debug.StartPerformance('Lua Code - Total')

		if containerTypeInfo.AttributeBindings[attributeCode].MultiplicityUpper == 1 then
			-- Single valued
			if attributeCount ~= 0 then
				local value = { Type = 'ComplexAttributeValue', Parent = container, ID = container.ID, AttributeCode = attributeCode, Index = 1 }

				setmetatable(value, attributeMetatable)

				container[attributeCode] = value
			end
		else
			-- Array
			local values = {}

			for i = 1, attributeCount do
				local value = { Type = 'ComplexAttributeValue', Parent = container, ID = container.ID, AttributeCode = attributeCode, Index = i }

				setmetatable(value, attributeMetatable)

				values[#values + 1] = value
			end

			container[attributeCode] = values
		end
	else
		Debug.StopPerformance('Lua Code - Total')
		local values = HostGetSimpleAttribute(container.ID, attributePath, attributeCode)
		Debug.StartPerformance('Lua Code - Total')

		--Debug.Break()

		if containerTypeInfo.AttributeBindings[attributeCode].MultiplicityUpper == 1 then
			-- Single valued
			local value = ConvertEncodedValue(simpleAttributeTypeInfo.ValueType, values[1])

			container['@' .. attributeCode] = value

			if value == unknownValue then
				value = nil
			end

			container[attributeCode] = value
			container['!' .. attributeCode] = value
		else
			-- Array
			local convertedValues = {}

			for i, value in ipairs(values) do
				local convertedValue = ConvertEncodedValue(simpleAttributeTypeInfo.ValueType, value)

				convertedValues['@' .. i] = convertedValue

				if convertedValue == unknownValue then
					convertedValue = nil
				end

				convertedValues[i] = convertedValue
			end

			container[attributeCode] = convertedValues
			container['!' .. attributeCode] = convertedValues
		end
	end

	stop_function_profiling(t__, 'LookupAttributeValue')
	return rawget(container, attributeCode1)
end

PrimitiveType =
{
	None       = { Type = 'PrimitiveType', Value = 0, Name = 'None' },
	Point      = { Type = 'PrimitiveType', Value = 1, Name = 'Point' },
	MultiPoint = { Type = 'PrimitiveType', Value = 2, Name = 'MultiPoint' },
	Curve      = { Type = 'PrimitiveType', Value = 3, Name = 'Curve' },
	Surface    = { Type = 'PrimitiveType', Value = 4, Name = 'Surface' },
	Coverage   = { Type = 'PrimitiveType', Value = 4, Name = 'Coverage' }
}

SpatialType =
{
	Point          = { Type = 'SpatialType', Value = 1, Name = 'Point' },
	MultiPoint     = { Type = 'SpatialType', Value = 2, Name = 'MultiPoint' },
	Curve          = { Type = 'SpatialType', Value = 3, Name = 'Curve' },
	CompositeCurve = { Type = 'SpatialType', Value = 4, Name = 'CompositeCurve' },
	Surface        = { Type = 'SpatialType', Value = 5, Name = 'Surface' }
}

Orientation =
{
	Forward = { Type = 'Orientation', Value = 1, Name = 'Forward' },
	Reverse = { Type = 'Orientation', Value = 2, Name = 'Reverse' }
}

Interpolation =
{
	None                             = { Type = 'Interpolation', value = 0, Name = 'None' },
	Linear                           = { Type = 'Interpolation', value = 1, Name = 'Linear' },
	Geodesic                         = { Type = 'Interpolation', value = 2, Name = 'Geodesic' },
	Arc3Points                       = { Type = 'Interpolation', value = 3, Name = 'Arc3Points' },
	Loxodromic                       = { Type = 'Interpolation', value = 4, Name = 'Loxodromic' },
	Elliptical                       = { Type = 'Interpolation', value = 5, Name = 'Elliptical' },
	Conic                            = { Type = 'Interpolation', value = 6, Name = 'Conic' },
	CircularArcCenterPointWithRadius = { Type = 'Interpolation', value = 7, Name = 'CircularArcCenterPointWithRadius' }
}

--
-- Type Information Creation Functions
--

function CreateItem(code, name, definition, remarks, alias)
	local t__ = start_function_profiling('CreateItem')
	CheckType(code, 'string')
	CheckType(name, 'string')
	CheckType(definition, 'string')
	CheckTypeOrNil(remarks, 'string')
	CheckTypeOrNil(alias, 'array:string')

	stop_function_profiling(t__, 'CreateItem')
	return { Type = 'Item', Code = code, Name = name, Definition = definition, Remarks = remarks, Alias  = alias }
end

--
--
--

local function CreateNamedTypeExact(item, abstract, attributeBindings)
	CheckType(item, 'Item', 2)
	CheckType(abstract, 'boolean', 2)
	CheckType(attributeBindings, 'array:AttributeBinding', 2)

	for _, ab in ipairs(attributeBindings) do
		attributeBindings[ab.AttributeCode] = ab
	end

	return DerivedType{ Type = 'NamedType', Base = item, Abstract = abstract, AttributeBindings = attributeBindings }
end

function CreateNamedType(...)
	local t__ = start_function_profiling('CreateNamedType')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		stop_function_profiling(t__, 'CreateNamedType')
		return CreateNamedTypeExact(unpack(params, 1, 3))
	else
		stop_function_profiling(t__, 'CreateNamedType')
		return CreateNamedTypeExact(CreateItem(unpack(params, 1, 5)), unpack(params, 6, 7))
	end
	stop_function_profiling(t__, 'CreateNamedType')
end

--
--
--

local function CreateObjectTypeExact(namedType, informationBindings)
	CheckType(namedType, 'NamedType', 2)
	CheckType(informationBindings, 'array:InformationBinding', 2)

	return DerivedType{ Type = 'ObjectType', Base = namedType, InformationBindings = informationBindings }
end

function CreateObjectType(...)
	local t__ = start_function_profiling('CreateObjectType')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		local ttype = params[1].Type

		if ttype == 'NamedType' then
			stop_function_profiling(t__, 'CreateObjectType')
			return CreateObjectTypeExact(unpack(params, 1, 2))
		else -- should be Item.  Checked in CreateNamedType call.
			stop_function_profiling(t__, 'CreateObjectType')
			return CreateObjectTypeExact(CreateNamedType(unpack(params, 1, 3)), unpack(params, 4, 4))
		end
	else
		stop_function_profiling(t__, 'CreateObjectType')
		return CreateObjectTypeExact(CreateNamedType(unpack(params, 1, 7)), unpack(params, 8, 8))
	end
	stop_function_profiling(t__, 'CreateObjectType')
end

--
--
--

local function CreateInformationTypeExact(objectType, superType, subType)
	CheckType(objectType, 'ObjectType', 2)
	CheckTypeOrNil(superType, 'InformationType', 2)
	CheckTypeOrNil(subType, 'array:InformationType', 2)

	return DerivedType{ Type = 'InformationType', Base = objectType, SuperType = superType, SubType = subType }
end

function CreateInformationType(...)
	local t__ = start_function_profiling('CreateInformationType')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		local ttype = params[1].Type

		if ttype == 'ObjectType' then
			stop_function_profiling(t__, 'CreateInformationType')
			return CreateInformationTypeExact(unpack(params, 1, 3))
		else
			Debug.Trace("Break in CreateInformationType")
			Debug.Break()
		end
	else
		stop_function_profiling(t__, 'CreateInformationType')
		return CreateInformationTypeExact(CreateObjectType(unpack(params, 1, 8)), unpack(params, 9, 10))
	end
	stop_function_profiling(t__, 'CreateInformationType')
end

--
--
--

local function CreateFeatureTypeExact(objectType, featureUseType, permittedPrimitives, featureBindings, superType, subType)
	CheckType(objectType, 'ObjectType', 2)
	CheckType(featureUseType, 'string', 2)
	CheckType(permittedPrimitives, 'array:string', 2)
	CheckType(featureBindings, 'array:FeatureBinding', 2)
	CheckTypeOrNil(superType, 'FeatureType', 2)
	CheckTypeOrNil(subType, 'array:FeatureType', 2)

	return DerivedType{ Type = 'FeatureType', Base = objectType, FeatureUseType = featureUseType, PermittedPrimitives = permittedPrimitives, FeatureBindings = featureBindings, SuperType = superType, SubType = subType }
end

function CreateFeatureType(...)
	local t__ = start_function_profiling('CreateFeatureType')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		local ttype = params[1].Type

		if ttype == 'ObjectType' then
			stop_function_profiling(t__, 'CreateFeatureType')
			return CreateFeatureTypeExact(unpack(params, 1, 6))
		else
			Debug.Trace("Break in CreateFeatureType")
			Debug.Break()
		end
	else
		stop_function_profiling(t__, 'CreateFeatureType')
		return CreateFeatureTypeExact(CreateObjectType(unpack(params, 1, 8)), unpack(params, 9, 13))
	end
	stop_function_profiling(t__, 'CreateFeatureType')
end

--
--
--

local function CreateInformationAssociationExact(namedType, roles, superType, subType)
	CheckType(namedType, 'NamedType', 2)
	CheckType(roles, 'array:Role', 2)
	CheckTypeOrNil(superType, 'InformationAssociation', 2)
	CheckTypeOrNil(subType, 'array:InformationAssociation', 2)

	return DerivedType{ Type = 'InformationAssociation', Base = namedType, Roles = roles, SuperType = superType, SubType = subType }
end

function CreateInformationAssociation(...)
	local t__ = start_function_profiling('CreateInformationAssociation')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		local ttype = params[1].Type

		if ttype == 'NamedType' then
			--Debug.Break() // < Is this break really needed? 
			stop_function_profiling(t__, 'CreateInformationAssociation')
			return CreateInformationAssociationExact(unpack(params, 1, 4))
		else
			Debug.Trace("Break in CreateInformationAssociation")
			Debug.Break()
		end
	else
		stop_function_profiling(t__, 'CreateInformationAssociation')
		return CreateInformationAssociationExact(CreateNamedType(unpack(params, 1, 7)), unpack(params, 8, 10))
	end
	stop_function_profiling(t__, 'CreateInformationAssociation')
end

--
--
--

local function CreateFeatureAssociationExact(namedType, roles, superType, subType)
	CheckType(namedType, 'NamedType', 2)
	CheckType(roles, 'array:Role', 2)
	CheckTypeOrNil(superType, 'FeatureAssociation', 2)
	CheckTypeOrNil(subType, 'array:FeatureAssociation', 2)

	return DerivedType{ Type = 'FeatureAssociation', Base = namedType, Roles = roles, SuperType = superType, SubType = subType }
end

function CreateFeatureAssociation(...)
	local t__ = start_function_profiling('CreateFeatureAssociation')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		local ttype = params[1].Type

		if ttype == 'NamedType' then
			-- Debug.Break() // < Is this break really needed? 
			stop_function_profiling(t__, 'CreateFeatureAssociation')
			return CreateFeatureAssociationExact(unpack(params, 1, 4))
		else
			Debug.Trace("CreateFeatureAssociation")
			Debug.Break()
		end
	else
		stop_function_profiling(t__, 'CreateFeatureAssociation')
		return CreateFeatureAssociationExact(CreateNamedType(unpack(params, 1, 7)), unpack(params, 8, 10))
	end
	stop_function_profiling(t__, 'CreateFeatureAssociation')
end

--
--
--

local function CreateRoleExact(item)
	CheckType(item, 'Item', 2)

	return DerivedType{ Type = 'Role', Base = item }
end

function CreateRole(...)
	local t__ = start_function_profiling('CreateRole')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		stop_function_profiling(t__, 'CreateRole')
		return CreateRoleExact(params[1])
	else
		stop_function_profiling(t__, 'CreateRole')
		return CreateRoleExact(CreateItem(unpack(params, 1, 5)))
	end
	stop_function_profiling(t__, 'CreateRole')
end

--
--
--

local function CreateSimpleAttributeExact(item, valueType, uom, quantitySpecification, attributeContraints, listedValues)
	CheckType(item, 'Item', 2)
	CheckType(valueType, 'string', 2)
	CheckTypeOrNil(uom, 'string', 2)
	CheckTypeOrNil(quantitySpecification, 'string', 2)
	CheckTypeOrNil(attributeContraints, 'AttributeConstraints', 2)
	CheckType(listedValues, 'array:ListedValue', 2)

	return DerivedType{ Type = 'SimpleAttribute', Base = item, ValueType = valueType, Uom = uom, QuantitySpecification = quantitySpecification, AttributeContraints = attributeContraints, ListedValues = listedValues }
end

function CreateSimpleAttribute(...)
	local t__ = start_function_profiling('CreateSimpleAttribute')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		stop_function_profiling(t__, 'CreateSimpleAttribute')
		return CreateSimpleAttributeExact(unpack(params, 1, 6))
	else
		stop_function_profiling(t__, 'CreateSimpleAttribute')
		return CreateSimpleAttributeExact(CreateItem(unpack(params, 1, 5)), unpack(params, 6, 10))
	end
	stop_function_profiling(t__, 'CreateSimpleAttribute')
end

--
--
--

local function CreateComplexAttributeExact(item, subAttributeBindings)
	CheckType(item, 'Item', 2)
	CheckType(subAttributeBindings, 'array:AttributeBinding', 2)

	for _, ab in ipairs(subAttributeBindings) do
		subAttributeBindings[ab.AttributeCode] = ab
	end

	return DerivedType{ Type = 'ComplexAttribute', Base = item, AttributeBindings = subAttributeBindings }
end

function CreateComplexAttribute(...)
	local t__ = start_function_profiling('CreateComplexAttribute')
	local params = {...}

	local ptype = type(params[1])

	if ptype == 'table' then
		stop_function_profiling(t__, 'CreateComplexAttribute')
		return CreateComplexAttributeExact(unpack(params, 1, 2))
	else
		stop_function_profiling(t__, 'CreateComplexAttribute')
		return CreateComplexAttributeExact(CreateItem(unpack(params, 1, 5)), unpack(params, 6, 6))
	end
	stop_function_profiling(t__, 'CreateComplexAttribute')
end

--
--
--

function CreateListedValue(label, definition, code, remarks, aliases)
	local t__ = start_function_profiling('CreateListedValue')
	CheckType(label, 'string', 2)
	CheckType(definition, 'string', 2)
	CheckType(code, 'number', 2)
	CheckTypeOrNil(remarks, 'string', 2)
	CheckTypeOrNil(aliases, 'array:string', 2)

	stop_function_profiling(t__, 'CreateListedValue')
	return { Type = 'ListedValue', Label = label, Definition = definition, Code = code, Remarks = remarks, Aliases = aliases }
end

--
--
--

function CreateAttributeBinding(attributeCode, lowerMultiplicity, upperMultiplicity, sequential, permittedValues)
	local t__ = start_function_profiling('CreateAttributeBinding')
	CheckType(attributeCode, 'string', 2)
	CheckType(lowerMultiplicity, 'number', 2)
	CheckTypeOrNil(upperMultiplicity, 'number', 2)
	CheckType(sequential, 'boolean', 2)
	CheckType(permittedValues, 'array:number', 2)

	stop_function_profiling(t__, 'CreateAttributeBinding')
	return { Type = 'AttributeBinding', AttributeCode = attributeCode, LowerMultiplicity = lowerMultiplicity, UpperMultiplicity = upperMultiplicity, Sequential = sequential, PermittedValues = permittedValues }
end

--
--
--

function CreateInformationBinding(informationTypeCode, lowerMultiplicity, upperMultiplicity, roleType, role, association)
	local t__ = start_function_profiling('CreateInformationBinding')
	CheckType(informationTypeCode, 'string', 2)
	CheckType(lowerMultiplicity, 'number', 2)
	CheckTypeOrNil(upperMultiplicity, 'number', 2)
	CheckType(roleType, 'string', 2)
	CheckTypeOrNil(role, 'Role', 2)
	CheckType(association, 'InformationAssociation', 2)

	stop_function_profiling(t__, 'CreateInformationBinding')
	return { Type = 'InformationBinding', InformationTypeCode = informationTypeCode, LowerMultiplicity = lowerMultiplicity, UpperMultiplicity = upperMultiplicity, RoleType = roleType, Role = role, Association = association }
end

--
--
--

function CreateFeatureBinding(featureTypeCode, lowerMultiplicity, upperMultiplicity, roleType, role, association)
	local t__ = start_function_profiling('CreateFeatureBinding')
	CheckType(featureTypeCode, 'string', 2)
	CheckType(lowerMultiplicity, 'number', 2)
	CheckTypeOrNil(upperMultiplicity, 'number', 2)
	CheckType(roleType, 'string', 2)
	CheckType(role, 'Role', 2)
	CheckType(association, 'FeatureAssociation', 2)

	stop_function_profiling(t__, 'CreateFeatureBinding')
	return { Type = 'FeatureBinding', FeatureTypeCode = featureTypeCode, LowerMultiplicity = lowerMultiplicity, UpperMultiplicity = upperMultiplicity, RoleType = roleType, Role = role, Association = association }
end

--
--
--

local featureCache = {}
local informationCache = {}
spatialCache = {}

function CreateAttributeBinding(attributeCode, multiplicityLower, multiplicityUpper, sequential, permittedValues)
	local t__ = start_function_profiling('CreateAttributeBinding')
	CheckType(attributeCode, 'string', 2)
	CheckType(multiplicityLower, 'number', 2)
	CheckTypeOrNil(multiplicityLower, 'number', 2)
	CheckType(sequential, 'boolean', 2)
	CheckTypeOrNil(permittedValues, 'array:number', 2)

	stop_function_profiling(t__, 'CreateAttributeBinding')
	return { Type = 'AttributeBinding', AttributeCode = attributeCode, MultiplicityLower = multiplicityLower, MultiplicityUpper = multiplicityUpper, Sequential = sequential, PermittedValues = permittedValues }
end

function CreateFeature(featureID, featureCode)
	local t__ = start_function_profiling('CreateFeature')
	Debug.StartPerformance('Lua Code - Total')
	local featureMetatable =
	{
		__index = function (t, k)
			local t__ = start_function_profiling('Feature:__index')
			if k == 'Spatial' or k == 'Point' or k == 'MultiPoint' or k == 'Curve' or k == 'CompositeCurve' or k == 'Surface' then
				local spatial = t:GetSpatial()

				--if spatial ~= nil then
					--t['SpatialType'] = spatial.SpatialType
				--end

				if k == 'Spatial' or spatial.SpatialType.Name == k then
					stop_function_profiling(t__, 'Feature:__index')
					return spatial
				end
				stop_function_profiling(t__, 'Feature:__index')
			elseif k == 'PrimitiveType' then
				local pt = PrimitiveType.None
				local sa = t:GetSpatialAssociation()

				if sa ~= nil then
					if sa.SpatialType == SpatialType.Point then
						pt = PrimitiveType.Point
					elseif sa.SpatialType == SpatialType.MultiPoint then
						pt = PrimitiveType.MultiPoint
					elseif sa.SpatialType == SpatialType.Curve or sa.SpatialType == SpatialType.CompositeCurve then
						pt = PrimitiveType.Curve
					elseif sa.SpatialType == SpatialType.Surface then
						pt = PrimitiveType.Surface
					end
				end
				
				t['PrimitiveType'] = pt
				stop_function_profiling(t__, 'Feature:__index')
				return pt
			elseif k == 'SpatialAssociations' then
				stop_function_profiling(t__, 'Feature:__index')
				return t:GetSpatialAssociations()
			else
				local av = LookupAttributeValue(t, k, HostFeatureGetSimpleAttribute, HostFeatureGetComplexAttributeCount)

				if av ~= nil then
					stop_function_profiling(t__, 'Feature:__index')
					return av
				end
				stop_function_profiling(t__, 'Feature:__index')
			end
			stop_function_profiling(t__, 'Feature:__index')
		end
	}

	local feature = featureCache[featureID]

	if feature then
		return feature
	end
	
	feature = { Type = 'Feature', ID = featureID, Code = featureCode, InformationAssociations = {} }

	featureCache[featureID] = feature

	function feature:GetInformationAssociations(associationCode, roleCode)
		-- Allow for passing in of informationTypeCode
		CheckSelf(self, 'Feature')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')

		local tuple = associationCode .. '|' .. (roleCode or '')

		local ias = self.InformationAssociations[tuple]

		if not ias then
			Debug.StopPerformance('Lua Code - Total')
			local informationIDs = HostFeatureGetAssociatedInformationIDs(self.ID, associationCode, roleCode)
			Debug.StartPerformance('Lua Code - Total')

			ias = {}

			for _, informationID in ipairs(informationIDs) do
				Debug.StopPerformance('Lua Code - Total')
				local code = HostInformationTypeGetCode(informationID)
				Debug.StartPerformance('Lua Code - Total')
				ias[#ias + 1] = CreateInformation(informationID, code)
			end

			self.InformationAssociations[tuple] = ias
		end

		return ias
	end

	function feature:GetInformationAssociation(associationCode, roleCode, informationTypeCode)
		CheckSelf(self, 'Feature')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')
		CheckTypeOrNil(informationTypeCode, 'string')

		local ias = self:GetInformationAssociations(associationCode, roleCode)
		
		if #ias ~= 0 then
			if informationTypeCode then
				for _, ia in ipairs(ias) do
					if ia.Code == informationTypeCode then
						return ia
					end
				end
			else
				return ias[1]
			end
		end
	end

	function feature:GetFeatureAssociations(associationCode, roleCode)
		-- Allow for passing in of featureTypeCode
		CheckSelf(self, 'Feature')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')

		local tuple = associationCode .. '|' .. (roleCode or '')

		local fas = self.FeatureAssociations[tuple]

		if not fas then
			Debug.StopPerformance('Lua Code - Total')
			local featureIDs = HostFeatureGetAssociatedFeatureIDs(self.ID, associationCode, roleCode)
			Debug.StartPerformance('Lua Code - Total')

			fas = {}

			for _, featureID in ipairs(featureIDs) do
				Debug.StopPerformance('Lua Code - Total')
				local code = HostFeatureTypeGetCode(featureID)
				Debug.StartPerformance('Lua Code - Total')
				fas[#fas + 1] = CreateFeature(featureID, code)
			end

			self.FeatureAssociations[tuple] = fas
		end

		return fas
	end

	function feature:GetFeatureAssociation(associationCode, roleCode, featureTypeCode)
		CheckSelf(self, 'Feature')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')

		local fas = self:GetFeatureAssociations(associationCode, roleCode)

		if fas then
			if featureTypeCode then
				for _, fa in ipairs(fas) do
					if fa.Code == featureTypeCode then
						return fa
					end
				end
			else
				return fas[1]
			end
		end
	end

	function feature:GetSpatialAssociations()
		CheckSelf(self, 'Feature')

		local sas = rawget(self, 'SpatialAssociations')

		Debug.StopPerformance('Lua Code - Total')
		sas = sas or HostFeatureGetSpatialAssociations(self.ID)
		Debug.StartPerformance('Lua Code - Total')

		self['SpatialAssociations'] = sas

		CheckTypeOrNil(sas, 'array:SpatialAssociation')

		return sas
	end

	function feature:GetSpatialAssociation()
		CheckSelf(self, 'Feature')

		-- TODO: Pick single association based on current scale.
		local sas = self:GetSpatialAssociations()

		if sas ~= nil then
			return sas[1]
		end
	end

	function feature:GetSpatial()
		CheckSelf(self, 'Feature')

		local sa = self:GetSpatialAssociation()

		if sa ~= nil then
			self['Spatial'] = sa.Spatial

			self[sa.SpatialType.Name] = self['Spatial']

			return self['Spatial']
		end
	end

	-- Returns an iterator that returns all spatial associations to points, multi points and curves
	-- associated to the feature.  Surface and composite curves return only their ultimate simple curves.
	-- This only works for features with a single spatial association.
	function feature:GetFlattenedSpatialAssociations()
		local spatialType = self:GetSpatialAssociation().SpatialType

		if contains(spatialType, { SpatialType.Point, SpatialType.MultiPoint, SpatialType.Curve }) then
			local first = true

			return function()
				if first then
					first = false
					return self:GetSpatialAssociation()
				end
			end
		elseif spatialType == SpatialType.CompositeCurve then
			local i = 0

			return function()
				i = i + 1
				return self.CompositeCurve.CurveAssociations[i]
			end
		elseif spatialType == SpatialType.Surface then
			-- Do this the hard way since coroutines don't play nice with C callbacks.
			local iRing = 0
			local iCurve = 0

			return function()
				local ring

				if iRing == 0 then
					ring = self.Surface.ExteriorRing
				else
					ring = self.Surface.InteriorRings[iRing]
				end

				while ring do
					if iCurve == 0 then
						if ring.SpatialType == SpatialType.Curve then
							iRing = iRing + 1
							return ring
						end
					end

					iCurve = iCurve + 1

					local ca = ring.Spatial.CurveAssociations[iCurve]

					if ca then
						return ca
					end

					iCurve = 0

					iRing = iRing + 1
					
					ring = self.Surface.InteriorRings[iRing]
				end
			end
		end
	end

	setmetatable(feature, featureMetatable)
	
	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateFeature')
	return feature
end

function CreateInformation(informationID, informationCode)
	local t__ = start_function_profiling('CreateInformation')
	Debug.StartPerformance('Lua Code - Total')

	local informationMetatable =
	{
		__index = function (t, k)
			local av = LookupAttributeValue(t, k, HostInformationTypeGetSimpleAttribute, HostInformationTypeGetComplexAttributeCount)

			if av ~= nil then
				return av
			end
		end
	}

	local information = informationCache[informationID];

	if information then
		return information
	end

	information = { Type = 'Information', ID = informationID, Code = informationCode }

	informationCache[informationID] = information

	function information:GetInformationAssociations(associationCode, roleCode)
		error('information:GetInformationAssociations not implemented.')
	end

	setmetatable(information, informationMetatable)

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateInformation')
	return information
end

function CreateSpatialAssociation(spatialType, spatialID, orientation, scaleMinimum, scaleMaximum)
	local t__ = start_function_profiling('CreateSpatialAssociation')
	Debug.StartPerformance('Lua Code - Total')

	local spatialAssociationMetatable =
	{
		__index = function (t, k)
			if k == 'Spatial' then
				Debug.StartPerformance('Lua Code - Spatial')
				local spatial = spatialCache[t.SpatialID]

				if not spatial then
					Debug.StartPerformance('Lua Code - HostGetSpatial')
					Debug.StopPerformance('Lua Code - Total')
					spatial = HostGetSpatial(t.SpatialID) or nilMarker
					Debug.StartPerformance('Lua Code - Total')
					Debug.StopPerformance('Lua Code - HostGetSpatial')

					spatialCache[t.SpatialID] = spatial

					if spatial ~= nilMarker then
						CheckType(spatial, 'Spatial')
						spatial['SpatialID'] = t.SpatialID
				
						t['Spatial'] = spatial
					else
						--Debug.Break()
					end
				else
					--Debug.Break()
				end

				Debug.StopPerformance('Lua Code - Spatial')
				if spatial ~= nilMarker then
					return spatial
				end
			elseif k == 'AssociatedFeatures' then
				return t:GetAssociatedFeatures()
			end
		end
	}

	if type(spatialType) == 'string' then
		spatialType = SpatialType[spatialType]
	end

	if type(orientation) == 'string' then
		orientation = Orientation[orientation]
	end

	CheckType(spatialType, 'SpatialType', 2)
	CheckTypeOrNil(orientation, 'Orientation', 2)
	CheckTypeOrNil(scaleMinimum, 'number', 2)
	CheckTypeOrNil(scaleMaximum, 'number', 2)

	local spatialAssociation = { Type = 'SpatialAssociation', SpatialType = spatialType, SpatialID = spatialID, Orientation = orientation, ScaleMinimum = scaleMinimum, ScaleMaximum = scaleMaximum, InformationAssociations = {} }

	function spatialAssociation:GetAssociatedFeatures()
		Debug.StopPerformance('Lua Code - Total')
		local featureIDs = HostSpatialGetAssociatedFeatureIDs(self.SpatialID)
		Debug.StartPerformance('Lua Code - Total')

		self.AssociatedFeatures = {}

		for _, featureID in ipairs(featureIDs) do
			self.AssociatedFeatures[#self.AssociatedFeatures + 1] = featureCache[featureID];

			CheckType(featureCache[featureID], 'Feature');
		end

		return self.AssociatedFeatures
	end

	function spatialAssociation:GetInformationAssociations(associationCode, roleCode)
		CheckSelf(self, 'SpatialAssociation')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')

		local tuple = associationCode .. '|' .. (roleCode or '')

		local ias = self.InformationAssociations[tuple]

		if not ias then
			Debug.StopPerformance('Lua Code - Total')
			local informationIDs = HostSpatialGetAssociatedInformationIDs(self.SpatialID, associationCode, roleCode)
			Debug.StartPerformance('Lua Code - Total')

			ias = {}

			for _, informationID in ipairs(informationIDs) do
				Debug.StopPerformance('Lua Code - Total')
				local code = HostInformationTypeGetCode(informationID)
				Debug.StartPerformance('Lua Code - Total')
				ias[#ias + 1] = CreateInformation(informationID, code)
			end

			self.InformationAssociations[tuple] = ias
		end

		return ias
	end

	function spatialAssociation:GetInformationAssociation(associationCode, roleCode, informationTypeCode)
		CheckSelf(self, 'SpatialAssociation')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')
		CheckTypeOrNil(informationTypeCode, 'string')

		local ias = self:GetInformationAssociations(associationCode, roleCode)

		if #ias ~= 0 then
			if informationTypeCode then
				for _, ia in ipairs(ias) do
					if ia.Code == informationTypeCode then
						return ia
					end
				end
			else
				return ias[1]
			end
		end
	end

	setmetatable(spatialAssociation, spatialAssociationMetatable)

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateSpatialAssociation')
	return spatialAssociation
end

local function CreateSpatial(spatialType, spatial)
	local t__ = start_function_profiling('CreateSpatial')
	CheckType(spatialType, 'SpatialType')

	local spatial = { Type = 'Spatial', SpatialType = spatialType, Spatial = spatial, InformationAssociations = {} }

	function spatial:GetInformationAssociations(associationCode, roleCode)
		CheckSelf(self, 'Spatial')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')

		local tuple = associationCode .. '|' .. (roleCode or '')

		local ias = self.InformationAssociations[tuple]

		if not ias then
			Debug.StopPerformance('Lua Code - Total')
			local informationIDs = HostSpatialGetAssociatedInformationIDs(self.SpatialID, associationCode, roleCode)
			Debug.StartPerformance('Lua Code - Total')

			ias = {}

			for _, informationID in ipairs(informationIDs) do
				Debug.StopPerformance('Lua Code - Total')
				local code = HostInformationTypeGetCode(informationID)
				Debug.StartPerformance('Lua Code - Total')
				ias[#ias + 1] = CreateInformation(informationID, code)
			end

			self.InformationAssociations[tuple] = ias
		end
		stop_function_profiling(t__, 'CreateSpatial')
		return ias
	end

	function spatial:GetInformationAssociation(associationCode, roleCode, informationTypeCode)
		CheckSelf(self, 'Spatial')
		CheckType(associationCode, 'string')
		CheckTypeOrNil(roleCode, 'string')
		CheckTypeOrNil(informationTypeCode, 'string')

		local ias = self:GetInformationAssociations(associationCode, roleCode)

		if #ias ~= 0 then
			if informationTypeCode then
				for _, ia in ipairs(ias) do
					if ia.Code == informationTypeCode then
						return ia
					end
				end
			else
				return ias[1]
			end
		end
	end

	stop_function_profiling(t__, 'CreateSpatial')
	return spatial
end

function CreatePoint(x, y, z)
	local t__ = start_function_profiling('CreatePoint')
	Debug.StartPerformance('Lua Code - Total')

	CheckType(x, 'string', 2)
	CheckType(y, 'string', 2)
	CheckTypeOrNil(z, 'string', 2)

	local point = CreateSpatial(SpatialType.Point, { X = tonumber(x), Y = tonumber(y), Z = tonumber(z), ScaledX = StringToScaledDecimal(x), ScaledY = StringToScaledDecimal(y), ScaledZ = StringToScaledDecimal(z) })

	point.X = point.Spatial.X
	point.Y = point.Spatial.Y
	point.Z = point.Spatial.Z
	point.ScaledX = point.Spatial.ScaledX
	point.ScaledY = point.Spatial.ScaledY
	point.ScaledZ = point.Spatial.ScaledZ

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreatePoint')
	return point
end

function CreateMultiPoint(points)
	local t__ = start_function_profiling('CreateMultiPoint')
	Debug.StartPerformance('Lua Code - Total')

	CheckType(points, 'array:Spatial', 2)

	local multiPoint = CreateSpatial(SpatialType.MultiPoint, points)

	multiPoint.Points = multiPoint.Spatial

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateMultiPoint')
	return multiPoint
end

function CreateCurveSegment(controlPoints, interpolation)
	local t__ = start_function_profiling('CreateCurveSegment')
	Debug.StartPerformance('Lua Code - Total')

	interpolation = interpolation or Interpolation.Loxodromic

	if type(interpolation) == 'string' then
		interpolation = Interpolation[interpolation]
	end

	CheckType(controlPoints, 'array:Spatial', 2)
	CheckType(interpolation, 'Interpolation', 2)

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateCurveSegment')
	return { Type = 'CurveSegment', ControlPoints = controlPoints, Interpolation = interpolation }
end

function CreateCurve(startPoint, endPoint, segments)
	local t__ = start_function_profiling('CreateCurve')
	Debug.StartPerformance('Lua Code - Total')

	CheckType(startPoint, 'Spatial', 2)
	CheckType(endPoint, 'Spatial', 2)
	CheckTypeOrNil(segments, 'array:CurveSegment', 2)

	local curve = CreateSpatial(SpatialType.Curve, { StartPoint = startPoint, EndPoint = endPoint, Segments = segments })

	curve.StartPoint = curve.Spatial.StartPoint
	curve.EndPoint = curve.Spatial.EndPoint
	curve.Segments = curve.Spatial.Segments

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateCurve')
	return curve
end

function CreateCompositeCurve(curveAssociations)
	local t__ = start_function_profiling('CreateCompositeCurve')
	Debug.StartPerformance('Lua Code - Total')

	CheckType(curveAssociations, 'array:SpatialAssociation', 2)

	local compositeCurve = CreateSpatial(SpatialType.CompositeCurve, curveAssociations)

	compositeCurve.CurveAssociations = compositeCurve.Spatial

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateCompositeCurve')
	return compositeCurve
end

function CreateSurface(exteriorRing, interiorRings)
	local t__ = start_function_profiling('CreateSurface')
	Debug.StartPerformance('Lua Code - Total')

	CheckType(exteriorRing, 'SpatialAssociation', 2)
	CheckType(interiorRings, 'array:SpatialAssociation', 2)

	local surface = CreateSpatial(SpatialType.Surface, { ExteriorRing = exteriorRing, InteriorRings = interiorRings })

	surface.ExteriorRing = surface.Spatial.ExteriorRing
	surface.InteriorRings = surface.Spatial.InteriorRings

	Debug.StopPerformance('Lua Code - Total')

	stop_function_profiling(t__, 'CreateSurface')
	return surface
end

function GetUnknownAttributeString()
	return '13BD40516CF742E886D5B4125DBB89742A043D0050E44B568CBB1FDDA8B464FF'
end

function EncodeDEFString(input)
	CheckType(input, 'string')

	input = input:gsub('&', '&a')
	input = input:gsub(';', '&s')
	input = input:gsub(':', '&c')
	input = input:gsub(',', '&m')

	return input
end

function DecodeDEFString(encodedString)
	CheckType(encodedString, 'string')

	encodedString = encodedString:gsub('&s', ';')
	encodedString = encodedString:gsub('&c', ':')
	encodedString = encodedString:gsub('&m', ',')
	encodedString = encodedString:gsub('&a', '&')

	return encodedString
end

local function JsonAppend(jsonTable, text)
	jsonTable[#jsonTable + 1] = text	
end

local function ConvertToJSONInternal(jsonTable, data)
	if type(data) == 'table' then
		if #data ~= 0 then
			JsonAppend(jsonTable, '[')

			for i, value in ipairs(data) do
				ConvertToJSONInternal(jsonTable, value)

				if i ~= #data then
					JsonAppend(jsonTable, ', ')
				end
			end

			JsonAppend(jsonTable, ']')
		else
			JsonAppend(jsonTable, '{')

			local first = true

			for key, value in pairs(data) do
				if type(value) ~= 'function' then
					if first then
						first = false
					else
						JsonAppend(jsonTable, ', ')
					end

					JsonAppend(jsonTable, '"')
					JsonAppend(jsonTable, key)
					JsonAppend(jsonTable, '" : ')

					ConvertToJSONInternal(jsonTable, value)
				end
			end

			JsonAppend(jsonTable, '}')
		end
	elseif type(data) == 'number' then
		JsonAppend(jsonTable, tostring(data))
	elseif type(data) == 'string' then
		JsonAppend(jsonTable, '"' .. data .. '"')
	elseif type(data) == 'boolean' then
		JsonAppend(jsonTable, data and 'true' or 'false')
	elseif data == nil then
		JsonAppend(jsonTable, 'null')
	else
		error('Unexpected type "' .. type(data) .. '" encountered.')
	end
end

function ConvertToJSON(data)
	if type(data) ~= 'table' then
		error('ConvertToJSON only supports table types', 2)
	end

	local jsonTable = {}

	ConvertToJSONInternal(jsonTable, data)

	return table.concat(jsonTable)
end

local function ConvertToJSONInternal1(data)
	if type(data) == 'table' then
		if #data ~= 0 then
			JsonAppend('[')

			for i, value in ipairs(data) do
				ConvertToJSONInternal(value)

				if i ~= #data then
					JsonAppend(', ')
				end
			end

			JsonAppend(']')
		else
			JsonAppend('{')

			local first = true

			for key, value in pairs(data) do
				if type(value) ~= 'function' then
					if first then
						first = false
					else
						JsonAppend(', ')
					end

					JsonAppend('"')
					JsonAppend(key)
					JsonAppend('" : ')

					ConvertToJSONInternal(value)
				end
			end

			JsonAppend('}')
		end
	elseif type(data) == 'number' then
		JsonAppend(tostring(data))
	elseif type(data) == 'string' then
		JsonAppend('"' .. data .. '"')
	elseif type(data) == 'boolean' then
		JsonAppend(data and 'true' or 'false')
	elseif data == nil then
		JsonAppend('null')
	else
		error('Unexpected type "' .. type(data) .. '" encountered.')
	end
end

function ConvertToJSON1(data)
	if type(data) ~= 'table' then
		error('ConvertToJSON only supports table types', 2)
	end

	ConvertToJSONInternal(data)
end
