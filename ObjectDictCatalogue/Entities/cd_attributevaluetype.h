﻿#pragma once

#include "enumtype.h"


enum class CD_AttributeValueTypes {
      /*
       * True or False
      */
      BOOLEAN,

      /*
       * List of predetermined values that can be expanded and
       * contracted
      */
      ENUMERATION,

      /*
       * Numeric value with defined range, units and format
      */
      INTEGER,

      /*
       * Floating point number
      */
      REAL,

      /*
       * A sequence of characters
      */
      TEXT,

      /*
       * Character encoding shall follow the format for date as
       * specified by ISO 8601
      */
      DATE,
  };

class CD_AttributeValueType : public EnumType<CD_AttributeValueTypes>
{
  public:
    CD_AttributeValueType() = default;
    CD_AttributeValueType(CD_AttributeValueTypes t);
    CD_AttributeValueType(std::string t);

  private:
    void initMaps();
};
