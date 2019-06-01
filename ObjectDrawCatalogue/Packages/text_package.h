#pragma once

#include "symbol_package.h"
#include <QVector>


namespace text_package {

enum class VerticalAlignment {
    TOP,
    BOTTOM,
    CENTER,
    BASELINE
};
VerticalAlignment toVerticalAlignment(const QString &type);

enum class HorizontalAlignment {
    START,
    END,
    CENTER
};
HorizontalAlignment toHorizontalAlignment(const QString &type);

enum class TextFlag {
    underLine,
    strikeThrough,
    upperLine
};

enum class FontSlant {
    UPRIGHT,
    ITALICS
};
FontSlant toFontSlant(const QString &type);

enum class FontWeight {
    LIGHT,
    MEDIUM,
    BOLD
};
FontWeight toFontWeight(const QString &type);

enum class FontProportion {
    MONO_SPACES,
    PROPORTIONAL
};
FontProportion toFontProportion(const QString &type);


class TextFlags
{
public:
    TextFlags();
private:
    QVector<TextFlag> m_flag;
};


class Font
{
public:
    Font() = default;
    virtual ~Font() = default;
};

class FontCharacteristics : public Font
{
public:
    FontCharacteristics(bool serifs, FontWeight weight, FontSlant slant, FontProportion proportion);
private:
    bool m_serifs;
    FontWeight m_weight;
    FontSlant m_slant;
    FontProportion m_proportion;
};

class FontReference : public Font
{
public:
    FontReference(QString reference);
private:
    QString m_reference;
};


class TextElement
{
public:
    TextElement(QString text_package, double bodySize, double verticalOffset, Font* font, graphic_base::Color foreground);
private:
    QString m_text;
    double m_bodySize;
    double m_verticalOffset;
    std::optional<TextFlags> m_flags;
    Font* m_font;
    graphic_base::Color m_foreground;
    std::optional<graphic_base::Color> m_background;
};


class Text
{
public:
    Text(HorizontalAlignment ha, VerticalAlignment va,  const QVector<TextElement>& elements);
private:
    HorizontalAlignment m_horizontalAlignment;
    VerticalAlignment m_verticalAlignment;
    QVector<TextElement> m_elements;
};


class TextPoint : public Text
{
public:
    TextPoint(HorizontalAlignment ha, VerticalAlignment va,  const QVector<TextElement>& elements
              ,double rotation);

    std::optional<symbol::AreaSymbolPlacement> areaPlacement() const;
    void setAreaPlacement(const symbol::AreaSymbolPlacement &areaPlacement);

private:
    std::optional<graphic_base::Vector> m_offset;
    double m_rotation;
    std::optional<symbol::AreaSymbolPlacement> m_areaPlacement;
};


class TextLine : public Text
{
public:
    TextLine(HorizontalAlignment ha, VerticalAlignment va,  const QVector<TextElement>& elements
             , double startOffset, symbol::LinePlacementMode placementMode);
private:
    double m_startOffset;
    std::optional<double> m_endOffset;
    symbol::LinePlacementMode m_placementMode;
};


};