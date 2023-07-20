class GameStatsFields {
    static final List<String> values = [
        word,embeddedInt
    ];
    static final String word = "_word";
    static final String embeddedInt = "answerHistoryEmbeddedInt";
}

class BoardGameStatsFields {
    static final List<String> values = [
        word, embeddedInt
    ];
    static final String word = "_word";
    static final String embeddedInt = "answerHistoryEmbeddedInt";
}

class GameStats {
    final String word;
    final int embeddedInt;

    const GameStats({
        required this.word,
        required this.embeddedInt,
    });

    Map<String,Object?> toJson() => {
        GameStatsFields.word : word,
        GameStatsFields.embeddedInt : embeddedInt,
    };

    static GameStats fromJson (Map<String,Object?> json) => GameStats(
        word: json[GameStatsFields.word] as String,
        embeddedInt: json[GameStatsFields.embeddedInt] as int,
    );
}