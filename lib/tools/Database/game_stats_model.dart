String gameStatsTable = "csw22_gamestats";

class GameStatsFields {
    static final List<String> values = [
        word,isWordCorrect,embeddedInt
    ];
    static final String word = "_word";
    static final String isWordCorrect = "isWordCorrect";
    static final String embeddedInt = "answerHistoryEmbeddedInt";
}

class GameStats {
    final String word;
    final bool isWordCorrect;
    final int embeddedInt;

    const GameStats({
        required this.word,
        required this.isWordCorrect,
        required this.embeddedInt,
    });

    Map<String,Object?> toJson() => {
        GameStatsFields.word : word,
        GameStatsFields.isWordCorrect : isWordCorrect ? 1 : 0,
        GameStatsFields.embeddedInt : embeddedInt,
    };

    static GameStats fromJson (Map<String,Object?> json) => GameStats(
        word: json[GameStatsFields.word] as String,
        isWordCorrect: (json[GameStatsFields.isWordCorrect] == 1) ? true : false,
        embeddedInt: json[GameStatsFields.embeddedInt] as int,
    );
}