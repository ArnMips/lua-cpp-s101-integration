#include "symbol_package.h"


symbol::LinePlacementMode symbol::toLinePlacementMode(const QString &type)
{
    const static QMap<QString, LinePlacementMode> toLinePlacementModeMap = {
        { "Relative", LinePlacementMode::RELATIVE },
        { "Absolute", LinePlacementMode::ABSOLUTE },
    };
    if (!toLinePlacementModeMap.contains(type)){
        qFatal("has no LinePlacementMode type in map");
    }
    return toLinePlacementModeMap[type];
}

symbol::AreaPlacementMode symbol::toAreaPlacementMode(const QString &type)
{
    const static QMap<QString, AreaPlacementMode> toAreaPlacementModeMap = {
        { "VisibleParts", AreaPlacementMode::VISIBLE_PARTS },
        { "Geographic", AreaPlacementMode::GEOGRAPHIC },
    };
    if (!toAreaPlacementModeMap.contains(type)){
        qFatal("has no AreaPlacementMode type in map");
    }
    return toAreaPlacementModeMap[type];
}

symbol::Symbol::Symbol(QString reference, double rotation, graphic_base::CRSType rotationCRS, graphic_base::Vector offset)
    :m_reference(reference), m_rotation(rotation), m_rotationCRS(rotationCRS), m_offset(offset)
{

}

std::optional<symbol::LineSymbolPlacement> symbol::Symbol::linePlacement() const
{
    return m_linePlacement;
}

void symbol::Symbol::setLinePlacement(const symbol::LineSymbolPlacement &linePlacement)
{
    m_linePlacement = std::make_optional(linePlacement);
}

std::optional<symbol::AreaSymbolPlacement> symbol::Symbol::areaPlacement() const
{
    return m_areaPlacement;
}

void symbol::Symbol::setAreaPlacement(const symbol::AreaSymbolPlacement &areaPlacement)
{
    m_areaPlacement = std::make_optional(areaPlacement);
}

symbol::LineSymbolPlacement::LineSymbolPlacement(double offset, symbol::LinePlacementMode placementMode)
    :m_offset(offset), m_placementMode(placementMode)
{

}

double symbol::LineSymbolPlacement::offset() const
{
    return m_offset;
}

symbol::LinePlacementMode symbol::LineSymbolPlacement::placementMode() const
{
    return m_placementMode;
}

symbol::AreaSymbolPlacement::AreaSymbolPlacement(symbol::AreaPlacementMode placementMode)
    :m_placementMode(placementMode)
{

}

symbol::AreaPlacementMode symbol::AreaSymbolPlacement::getPlacementMode() const
{
    return m_placementMode;
}