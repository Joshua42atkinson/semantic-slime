--!strict

export type WordStats = {
    Logos: number,
    Pathos: number,
    Ethos: number,
    Speed: number
}

export type WordInstance = {
    InstanceId: string,   -- Unique UUID for this specific collected word
    WordId: string,       -- The word itself (e.g. "run", "happy")
    Term: string,         -- Display text
    XP: number,
    Level: number,
    EvolutionStage: number,
    Element: string,      -- Fire, Water, etc. (derived from Root)
    Role: string,         -- Tank, Striker, etc. (derived from Suffix)
    Stats: WordStats,
    History: { [string]: boolean } -- Record of usage contexts?
}

return {}
