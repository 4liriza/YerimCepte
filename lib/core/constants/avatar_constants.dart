class AvatarConstants {
  static const String baseUrl = "https://api.dicebear.com/7.x";

  static final Map<String, List<String>> avatarCategories = {
    "Kız": [
      "$baseUrl/avataaars/png?seed=Luna",
      "$baseUrl/avataaars/png?seed=Zoe",
      "$baseUrl/avataaars/png?seed=Mia",
      "$baseUrl/avataaars/png?seed=Chloe",
    ],
    "Erkek": [
      "$baseUrl/avataaars/png?seed=Jack",
      "$baseUrl/avataaars/png?seed=Oliver",
      "$baseUrl/avataaars/png?seed=Leo",
      "$baseUrl/avataaars/png?seed=Max",
    ],
    "Uzay & Robot": [
      "$baseUrl/bottts/png?seed=Robot1",
      "$baseUrl/bottts/png?seed=Alien",
      "$baseUrl/bottts/png?seed=Space",
      "$baseUrl/bottts/png?seed=Blee",
    ],
    "Hayvan": [
      "$baseUrl/adventurer-neutral/png?seed=Bear",
      "$baseUrl/adventurer-neutral/png?seed=Cat",
      "$baseUrl/adventurer-neutral/png?seed=Dog",
      "$baseUrl/adventurer-neutral/png?seed=Fox",
    ],
    "Pixel Art": [
      "$baseUrl/pixel-art/png?seed=P1",
      "$baseUrl/pixel-art/png?seed=P2",
      "$baseUrl/pixel-art/png?seed=P3",
      "$baseUrl/pixel-art/png?seed=P4",
    ],
    "Nesne": [
      "$baseUrl/identicon/png?seed=Book",
      "$baseUrl/identicon/png?seed=Lamp",
      "$baseUrl/identicon/png?seed=Pen",
      "$baseUrl/identicon/png?seed=Library",
    ],
  };

  static String get defaultAvatar => "$baseUrl/avataaars/png?seed=Felix";
}
