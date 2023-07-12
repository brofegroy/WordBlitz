String gameStatsTable = "csw22_gamestats";

class GameStatsFields {
    static final List<String> values = [
        word,isWordCorrect,correctGuesses,misses,wrongGuesses,total,
    ];

    static final String word = "_word";
    static final String isWordCorrect = "isWordCorrect";
    static final String correctGuesses = "correctGuesses";
    static final String misses = "misses";
    static final String wrongGuesses = "wrongGuesses";
    static final String total = "total";
}

class GameStats {
    final String word;
    final bool isWordCorrect;
    final int correctGuesses;
    final int misses;
    final int wrongGuesses;
    final int total;

    const GameStats({
        required this.word,
        required this.isWordCorrect,
        required this.correctGuesses,
        required this.misses,
        required this.wrongGuesses,
        required this.total
    });

    Map<String,Object?> toJson() => {
        GameStatsFields.word : word,
        GameStatsFields.isWordCorrect : isWordCorrect ? 1 : 0,
        GameStatsFields.correctGuesses : correctGuesses,
        GameStatsFields.misses : misses,
        GameStatsFields.wrongGuesses : wrongGuesses,
        GameStatsFields.total : total,
    };

    static GameStats fromJson (Map<String,Object?> json) => GameStats(
        word: json[GameStatsFields.word] as String,
        isWordCorrect: (json[GameStatsFields.isWordCorrect] == 1) ? true : false,
        correctGuesses: json[GameStatsFields.correctGuesses] as int,
        misses: json[GameStatsFields.misses] as int,
        wrongGuesses: json[GameStatsFields.wrongGuesses] as int,
        total: json[GameStatsFields.total] as int,
    );
}