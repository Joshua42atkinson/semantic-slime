--!strict
-- LearningStationData.lua
-- Defines learning stations for each building in Syllable Springs
-- These provide educational content about etymology and word roots

export type LearningStation = {
	Id: string,
	Title: string,
	Content: string,
	WordRoot: string?,
	District: string,
	BuildingName: string,
}

local LearningStationData: { [string]: LearningStation } = {
	-- LOGOS DISTRICT (North) - Knowledge & Logic
	["BrainyBorough_CityHall"] = {
		Id = "BrainyBorough_CityHall",
		Title = "The Hall of Words",
		Content = "Welcome to the City Hall! Here we study the LOGOS - the logic and reason behind words. Did you know that most English words derive from Latin and Greek roots? Understanding etymology helps unlock the meaning of thousands of words!",
		WordRoot = "BrainyBorough",
		District = "BrainyBorough",
		BuildingName = "City Hall",
	},
	["BrainyBorough_Archive"] = {
		Id = "BrainyBorough_Archive",
		Title = "The Great Archive",
		Content = "The Archive contains the wisdom of ages! Words here represent the building blocks of language: roots, prefixes, and suffixes. The root 'FERRUM' means iron - giving us words like 'ferrous', 'ferry', and 'conifer'!",
		WordRoot = "Ignis",
		District = "BrainyBorough",
		BuildingName = "The Archive",
	},
	["BrainyBorough_Forge"] = {
		Id = "BrainyBorough_Forge",
		Title = "The Word Forge",
		Content = "At the Forge, we forge new words! The root IGNIS means fire in Latin. Words like 'ignite', 'igneous', and 'ignescent' all trace back to this fiery root. Fire represents transformation!",
		WordRoot = "Ignis",
		District = "BrainyBorough",
		BuildingName = "The Forge",
	},
	
	-- EROS DISTRICT (South) - Nature & Growth
	["HeartwoodGrove_Sanctuary"] = {
		Id = "HeartwoodGrove_Sanctuary",
		Title = "The Sanctuary of Meaning",
		Content = "Welcome to the Sanctuary! Here we explore how words grow like plants. The suffix -OUS means 'having quality of' - like 'joyous', 'generous', and 'vigorous'. Words are living things!",
		WordRoot = "Terra",
		District = "HeartwoodGrove",
		BuildingName = "The Sanctuary",
	},
	["HeartwoodGrove_Garden"] = {
		Id = "HeartwoodGrove_Garden",
		Title = "The Word Garden",
		Content = "In our garden, words bloom! The Greek root PHYTO means plant - giving us 'photosynthesis', 'phytoplankton', and 'apathy' (without feeling, from 'pathos'). Even 'physician' comes from plants!",
		WordRoot = "Aqua",
		District = "HeartwoodGrove",
		BuildingName = "The Garden",
	},
	["HeartwoodGrove_Market"] = {
		Id = "HeartwoodGrove_Market",
		Title = "The Word Market",
		Content = "Welcome to the market! Words have value too. The Latin root MERC means trade - giving us 'merchant', 'commerce', 'mercury', and even 'market' itself! Language is the currency of ideas.",
		WordRoot = "Lux",
		District = "HeartwoodGrove",
		BuildingName = "The Market",
	},
	
	-- PNEUMA DISTRICT (East) - Spirit & Light
	["WhisperWinds_Observatory"] = {
		Id = "WhisperWinds_Observatory",
		Title = "The Star Observatory",
		Content = "Gaze upon the stars of language! The Latin root LUX means light. Words like 'lucid', 'illuminate', and 'luxury' all stem from light. In WhisperWinds, we seek enlightenment through words!",
		WordRoot = "Lux",
		District = "WhisperWinds",
		BuildingName = "The Observatory",
	},
	["WhisperWinds_Spire"] = {
		Id = "WhisperWinds_Spire",
		Title = "The Cloud Spire",
		Content = "From up here, we see the AER (air) around us! The Greek root AER gives us 'aerial', 'aerospace', 'aerobic', and even 'air' itself. Breathe deep and absorb knowledge!",
		WordRoot = "Aer",
		District = "WhisperWinds",
		BuildingName = "Cloud Spire",
	},
	["WhisperWinds_Carnival"] = {
		Id = "WhisperWinds_Carnival",
		Title = "The Festival of Words",
		Content = "Celebrate language! The Latin root FEST means feast/holiday - giving us 'festival', 'festive', and 'festoon'. Joy and celebration are part of learning too!",
		WordRoot = "Umbra",
		District = "WhisperWinds",
		BuildingName = "The Carnival",
	},
	
	-- SOMA DISTRICT (West) - Body & Primal
	["ActionAlley_Arena"] = {
		Id = "ActionAlley_Arena",
		Title = "The Battle of Words",
		Content = "Welcome to the Arena! Strength matters here. The Latin root FORT means strong - giving us 'fortress', 'fortify', 'effort', and 'fortune'. Words have power!",
		WordRoot = "Terra",
		District = "ActionAlley",
		BuildingName = "The Arena",
	},
	["ActionAlley_Docks"] = {
		Id = "ActionAlley_Docks",
		Title = "The Harbor of Meanings",
		Content = "Words dock here from distant shores! The Latin root PORT means carry - giving us 'transport', 'porter', 'portfolio', and 'port'. Ideas travel across languages!",
		WordRoot = "Aqua",
		District = "ActionAlley",
		BuildingName = "The Docks",
	},
	["ActionAlley_Undercity"] = {
		Id = "ActionAlley_Undercity",
		Title = "The Hidden Depths",
		Content = "Beneath the surface lie secrets. The Latin root UMBRA means shadow - giving us 'umbrella' (shadow-maker), 'umbrage', and 'penumbra'. Shadows hide and reveal!",
		WordRoot = "Umbra",
		District = "ActionAlley",
		BuildingName = "The Undercity",
	},
}

-- Get all stations for a district
local function getStationsForDistrict(districtName: string): { LearningStation }
	local stations = {}
	for _, station in pairs(LearningStationData) do
		if station.District == districtName then
			table.insert(stations, station)
		end
	end
	return stations
end

-- Get station for a specific building
local function getStationForBuilding(buildingName: string, districtName: string): LearningStation?
	for _, station in pairs(LearningStationData) do
		if station.BuildingName == buildingName and station.District == districtName then
			return station
		end
	end
	return nil
end

return {
	Stations = LearningStationData,
	GetForDistrict = getStationsForDistrict,
	GetForBuilding = getStationForBuilding,
}
