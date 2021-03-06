#pragma once

#include <sol/sol.hpp>
#include <QVector>

#include <vector>
#include <string>

class ContexParametrController;
class ContextParameter;

class UnlimitedInteger;
class FC_Item;
class FC_Role;
class FC_FeatureAssociation;
class FC_InformationAssociation;
class FC_SimpleAttribute;
class FC_ComplexAttribute;
class FC_ListedValue;
class FC_AttributeBinding;
class FC_InformationBinding;
class FC_FeatureBinding;

class GM_Point;
class GM_Curve;
class GM_MultiPoint;
class GM_CurveSegment;
class GM_CompositeCurve;
class GM_Surface;

class Fe2spRef;

//-----------------------------------------------------------------------------
// Helper Host Create Functions
sol::table helpCreateAttributeBindings(sol::state &lua, const QVector<FC_AttributeBinding> &atrBinds);
sol::table helpCreateInformationBindings(sol::state &lua, const QVector<FC_InformationBinding> &infBinds);
sol::table helpCreateFeatureBindings(sol::state &lua, const QVector<FC_FeatureBinding> &featBinds);
sol::table helpCreatePointsArray(sol::state &lua, const QVector<GM_Point>& points);
sol::table helpCreateSpatialAssociations(sol::state &lua, const QVector<Fe2spRef> &spatialAssociations);
sol::table helpCreateRoles(sol::state &lua, const QVector<FC_Role> &roles);

template<typename T>
sol::table helpLuaTable(sol::state &lua, const std::vector<T> &seq)
{
    sol::table luaRoles = lua.create_table();
    for (const auto &s : seq) {
        luaRoles.add(s);
    }
    return luaRoles;
}

sol::table helpEmptyTable(sol::state& lua);

//-----------------------------------------------------------------------------
// 9a-14.1 Portrayal Domain Specific Catalogue Functions
/** The functions listed on the following clauses are implemented within the Portrayal Catalogue rule
 * files. They can be called by the host, and augment the standard catalogue functions described in
 * Part 13.
 */
/*!
 * \brief PortrayalMain
 * \param featureIDs: String[]
 *          > An array containing the IDs of the features for which to generate drawing instructions. If
 *            this parameter is nil (or missing), the portrayal will generate drawing instructions for all
 *            feature instances in the dataset.
 * \return True
 *          > Portrayal completed successfully.
 * \return False
 *          > Portrayal was terminated by the host (host returned false from HostPortrayalEmit).
 * \remarks
 *          This function is called by the host to start the portrayal process for a dataset instance.
 *          Subsequently, the portrayal scripts will repeatedly call HostPortrayalEmit, providing the host with
 *          the drawing instructions for each feature instance portrayed.
 *          The function returns once the portrayal scripts have run to completion; an error is thrown; or the
 *          host returns false from HostPortrayalEmit.
 *          If using a portrayal cache as outlined in clause 9a-5.2.2.1, the host only needs to pass in
 *          uncached featureIDs, or featureIDs associated with context parameters whose values have
 *          changed.
 */
bool PortrayalMain(sol::state &lua, const std::vector<std::string> &featureIDs);

/*!
 * \brief PortrayalInitializeContextParameters
 * \param featureIDs: String[]
 *          > An array containing the IDs of the features for which to generate drawing instructions. If
 *            this parameter is nil (or missing), the portrayal will generate drawing instructions for all
 *            feature instances in the dataset.
 * \return True
 *          > Portrayal completed successfully.
 * \return False
 *          > Portrayal was terminated by the host (host returned false from HostPortrayalEmit).
 * \remarks
 *          This function is called by the host to start the portrayal process for a dataset instance.
 *          Subsequently, the portrayal scripts will repeatedly call HostPortrayalEmit, providing the host with
 *          the drawing instructions for each feature instance portrayed.
 *          The function returns once the portrayal scripts have run to completion; an error is thrown; or the
 *          host returns false from HostPortrayalEmit.
 *          If using a portrayal cache as outlined in clause 9a-5.2.2.1, the host only needs to pass in
 *          uncached featureIDs, or featureIDs associated with context parameters whose values have
 *          changed.
 */
void PortrayalInitializeContextParameters(sol::state &lua, const ContexParametrController &contextParameters );


/*!
 * \brief PortrayalCreateContextParameter
 * \param contextParameterName: String
 *          > An array containing the IDs of the features for which to generate drawing instructions. If
 *            this parameter is nil (or missing), the portrayal will generate drawing instructions for all
 *            feature instances in the dataset.
 * \param contextParameterType: String
 *          > The name of a portrayal context parameter. Valid names are defined in the Portrayal
 *            Catalogue.
 * \param contextParameterName: String
 *          > The type of the portrayal context parameter. Valid values are Boolean, Integer, Real, Text
 *            and Date.
 * \param defaultValue: String
 *          > The default value for the portrayal context parameter. This value is encoded as described
 *            in Part 13 clause 13-8.1.
 * \return ContextParameter
 *          > A ContextParameter storing the defaultValue with the contextParameterName.
 * \remarks
 *          Creates a ContextParameter object for use within the scripting environment.
 */
sol::object PortrayalCreateContextParameter(const sol::state &lua, const ContextParameter& param);


//-----------------------------------------------------------------------------
//13-8.1.1 Object Creation Functions
/** These functions relieve the host from the burden of constructing Lua tables corresponding to
 * complex types used within the scripting catalogue. They allow the host to create objects
 * which will be passed into the scripting catalogue. The schema and contents of the created
 * objects are opaque to the host – they are only intended for use within the scripting catalogue.
*/

//13-8.1.1.1
sol::object luaCreateSpatialAssociation(const sol::state &lua, const Fe2spRef& spAssociation);

//13-8.1.1.2
sol::object luaCreatePoint(const sol::state &lua, const GM_Point& point);

//13-8.1.1.3
sol::object luaCreateMultiPoint(sol::state &lua, const GM_MultiPoint& mp);

//13-8.1.1.4
sol::object luaCreateCurveSegment(sol::state &lua, const GM_CurveSegment& cs);

//13-8.1.1.5
sol::object luaCreateCurve(sol::state &lua, const GM_Curve& c);

//13-8.1.1.6
sol::object luaCreateCompositeCurve(sol::state &lua, const GM_CompositeCurve& cc);

//13-8.1.1.7
sol::object luaCreateSurface(sol::state &lua, const GM_Surface& ss);



//-----------------------------------------------------------------------------
// 13-8.1.2 Type Information Creation Functions
/** The functions listed on the following clauses are implemented within the Portrayal Catalogue rule
 * files. They can be called by the host, and augment the standard catalogue functions described in
 * Part 13.
 */

//13-8.1.2.1
sol::object luaCreateItem(sol::state &lua, const FC_Item *item);

//13-8.1.2.2
sol::object luaCreateNamedType(const sol::state& lua, const sol::object &luaItem, const sol::table& luaAttributeBindingArr);

//13-8.1.2.3
sol::object luaCreateObjectType(const sol::state& lua, const sol::object &LuaNamedType, const sol::table &LuaInformationBindings = sol::table());

//13-8.1.2.4
sol::object luaCreateInformationType(const sol::state& lua, sol::object luaObjectType, sol::object luaSuperType, sol::table luaSubTypes);

//13-8.1.2.5
sol::table luaCreateFeatureType(const sol::state& lua, const sol::object& luaObjectType, const std::string &featureUseType, const sol::table &permittedPrimitives, const sol::table &luaFeatureBindings, sol::object luaSuperType = sol::nil, sol::table luaSubType = sol::table());

//13-8.1.2.6
sol::object luaCreateInformationAssociation(sol::state &lua, const FC_InformationAssociation *infAss);

//13-8.1.2.7
sol::object luaCreateFeatureAssociation(sol::state &lua, const FC_FeatureAssociation *featureAssocoation);

//13-8.1.2.8
sol::object luaCreateRole(sol::state &lua, const FC_Role *role);

//13-8.1.2.9
sol::object luaCreateSimpleAttribute(sol::state &lua, const FC_SimpleAttribute *simpleAttr);

//13-8.1.2.10
sol::object luaCreateComplexAttribute(sol::state &lua, const FC_ComplexAttribute *complAttr);

//13-8.1.2.11
sol::object luaCreateListedValue(sol::state &lua, const FC_ListedValue *listedValue);

//13-8.1.2.12
sol::object luaCreateAttributeBinding(sol::state &lua, const FC_AttributeBinding *attrBind);

//13-8.1.2.13
sol::object luaCreateInformationBinding(sol::state &lua, const FC_InformationBinding *infBind);

//13-8.1.2.14
sol::object luaCreateFeatureBinding(sol::state &lua, const FC_FeatureBinding *featureBinding);


//-----------------------------------------------------------------------------
// 13-8.1.3 Miscellaneous Functions
/** The functions described on the following pages do not fall under one of the previously
 * described functionalities.
 */

sol::object luaGetUnknownAttributeString(sol::state &lua);
