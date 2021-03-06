#include "featurecataloguecontroller.h"



FeatureCatalogueController::FeatureCatalogueController()
{
}

void FeatureCatalogueController::addSimpleAttr(const FC_SimpleAttribute &sa)
{
    m_simpleAttributeCtrl.addType(sa);
}

void FeatureCatalogueController::addComplexAttr(const FC_ComplexAttribute &ca)
{
    m_complexAttributeCtrl.addType(ca);
}

void FeatureCatalogueController::addFeatureType(const FC_FeatureType &ft)
{
    m_featureTypeCtrl.addType(ft);
}

void FeatureCatalogueController::addInformationType(const FC_InformationType &it)
{
    m_informationTypeCrtl.addType(it);
}

void FeatureCatalogueController::addFeatureAssociation(const FC_FeatureAssociation &fa)
{
    m_featureAssociationCtrl.addType(fa);
}

void FeatureCatalogueController::addInformationAssociation(const FC_InformationAssociation &ia)
{
    m_informationAssociationCtrl.addType(ia);
}

void FeatureCatalogueController::addRole(const FC_Role &r)
{
    m_rolesCtrl.addType(r);
}

const EntityController<FC_SimpleAttribute> &FeatureCatalogueController::simpleAttributeCtrl() const
{
    return m_simpleAttributeCtrl;
}

const EntityController<FC_ComplexAttribute> &FeatureCatalogueController::complexAttributeCtrl() const
{
    return m_complexAttributeCtrl;
}

const EntityController<FC_Role> &FeatureCatalogueController::rolesCtrl() const
{
    return m_rolesCtrl;
}

const EntityController<FC_InformationAssociation> &FeatureCatalogueController::informationAssociationCtrl() const
{
    return m_informationAssociationCtrl;
}

const EntityController<FC_FeatureAssociation> &FeatureCatalogueController::featureAssociationCtrl() const
{
    return m_featureAssociationCtrl;
}

const EntityController<FC_InformationType> &FeatureCatalogueController::informationTypeCrtl() const
{
    return m_informationTypeCrtl;
}

const EntityController<FC_FeatureType> &FeatureCatalogueController::featureTypeCtrl() const
{
    return m_featureTypeCtrl;
}
