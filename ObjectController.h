#pragma once

#include <vector>
#include <string>
#include <map>

//* ��� ��� �� ����� �� ������ ������� ����������� SpatialID-SpatialType ������ ����� ������� �� ������������
// ������������ � LuaRuleMashine.cpp ������: 79, 81, 83, 87, 88, 103
// ����� � �������� �� ���-�� ����� ����������.
// (SpatialType � ��� �������� (������� � Lua �������, SpatialID �� ��� ���� �� ����� ������)
// ��� ���� ������ ������ SpatialID's <- ��������� (�� ���� ��������)



class Object 
{
public:
  static const char* NO_SPATIAL;
  static const char* NO_SIMPLE_ATTRIBUTE;
public:
	Object() = default;
	Object(std::string ID, std::string code, 
    std::string datasetID, std::string spatialID,
    std::map<std::string, int> simpleAttributes);

	void setDrawInstructions(std::string drawInstructions);
	std::vector<std::string> getDrawInstructions() const;

	static std::string toSpatialType(const std::string& spatialID);

	std::string getID() const;
	std::string getCode() const;
	std::string getDatasetID() const;
	std::string getSpatialID() const;
  int         getSimpleAttributeValue(std::string code) const;

private:
	std::string ID_;
	std::string code_;
	std::string datasetID_;
	std::string spatialID_;
  std::map<std::string, int> simpleAttributes_;  /* pairs of [attributeCode, value] */
	std::vector<std::string> drawInstructions_;

  static std::map<std::string, std::string> spatials;
};


class ObjectController
{
public:
	ObjectController() = default;
	void setObjects(std::string datasedID);
	std::vector<Object> getObjects() const;
	
	static void printInformation(const std::vector<Object>&);

	const Object& getObject(std::string objectID) const;
	void setDrawInstructions(std::string objectID, std::string drawInstructions);

private:
	const std::string path = "features_code/";

	std::vector<Object> objects_;
	std::map<std::string, int> objectIndexByID_;
};