class HeritagePlace {
  final String name;
  final String location;
  final String image;
  final String rating;
  final String price;
  final String category;
  final String description;

  const HeritagePlace({
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    required this.price,
    required this.category,
    required this.description,
  });

  static const _featured = [
    HeritagePlace(
      name: 'Pyramids of Giza',
      location: 'Giza, Egypt',
      image: 'assets/images/pyramids.png',
      rating: '4.9',
      price: '300 EGP',
      category: 'Monuments',
      description:
          'The Giza Necropolis stands as a testament to the architectural prowess of the Old Kingdom\'s Fourth Dynasty. As the only remaining wonder of the ancient world, these sandstone giants have witnessed four millennia of human history.',
    ),
    HeritagePlace(
      name: 'Karnak Temple',
      location: 'Luxor, Egypt',
      image: 'assets/images/karnak.jpg',
      rating: '4.8',
      price: '250 EGP',
      category: 'Temples',
      description:
          'The Karnak Temple Complex is a vast open-air museum and the largest ancient religious site in the world. It was the most important place of worship in ancient Egypt for over 2,000 years.',
    ),
    HeritagePlace(
      name: 'Great Sphinx',
      location: 'Giza, Egypt',
      image: 'assets/images/sphinex.jpg',
      rating: '4.7',
      price: '200 EGP',
      category: 'Monuments',
      description:
          'The Great Sphinx of Giza is a limestone statue of a reclining sphinx — a mythical creature with the head of a human and the body of a lion. It is the oldest known monumental sculpture in Egypt.',
    ),
    HeritagePlace(
      name: 'Abu Simbel',
      location: 'Aswan, Egypt',
      image: 'assets/images/karnak.jpg',
      rating: '4.9',
      price: '450 EGP',
      category: 'Temples',
      description:
          'Abu Simbel is an ancient temple complex carved into a mountainside during the reign of Pharaoh Ramesses II in the 13th century BCE. The temples were relocated in 1968 to avoid flooding from Lake Nasser.',
    ),
    HeritagePlace(
      name: 'Luxor Temple',
      location: 'Luxor, Egypt',
      image: 'assets/images/sphinex_close.jpg',
      rating: '4.6',
      price: '160 EGP',
      category: 'Temples',
      description:
          'Luxor Temple is a large ancient Egyptian temple complex located on the east bank of the Nile River. Unlike other temples in the area, Luxor Temple is not dedicated to a cult deity or a deified pharaoh.',
    ),
  ];

  // Extended browsing-only catalog. These entries are NOT imported from the
  // user's source CSV and do not claim verified pricing, ratings or schedules.
  static const _additional = [
    HeritagePlace(name: 'Egyptian Museum', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'National Museum of Egyptian Civilization', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Museum of Islamic Art', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Coptic Museum', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Gayer-Anderson Museum', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Manial Palace Museum', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Al-Azhar Mosque', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Mosques', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Mosque of Muhammad Ali', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Mosques', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Sultan Hassan Mosque', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Mosques', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Al-Rifa’i Mosque', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Mosques', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Ibn Tulun Mosque', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Mosques', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Cairo Citadel', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Bab Zuweila', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Baron Empain Palace', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Hanging Church', location: 'Cairo, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Cairo. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Grand Egyptian Museum', location: 'Giza, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Giza. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Imhotep Museum', location: 'Giza, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Giza. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Saqqara Step Pyramid', location: 'Giza, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Giza. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Dahshur Bent Pyramid', location: 'Giza, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Giza. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Dahshur Red Pyramid', location: 'Giza, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Giza. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Memphis Open-Air Museum', location: 'Giza, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Giza. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Alexandria National Museum', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Royal Jewelry Museum', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Graeco-Roman Museum', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Citadel of Qaitbay', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Catacombs of Kom El Shoqafa', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Pompey’s Pillar', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Roman Amphitheatre', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Montaza Palace Gardens', location: 'Alexandria, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Alexandria. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Luxor Museum', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Mummification Museum', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Temple of Hatshepsut', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Medinet Habu', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Ramesseum', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Temple of Seti I', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Valley of the Kings', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Valley of the Queens', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Colossi of Memnon', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Deir el-Medina', location: 'Luxor, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Luxor. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Nubian Museum', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Aswan Museum', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Philae Temple', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Temple of Kom Ombo', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Kalabsha Temple', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Unfinished Obelisk', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Tombs of the Nobles', location: 'Aswan, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Aswan. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Dendera Temple Complex', location: 'Qena, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Qena. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Abydos Temple', location: 'Sohag, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Sohag. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Temple of Seti I at Abydos', location: 'Sohag, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Sohag. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'White Monastery', location: 'Sohag, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Sohag. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Red Monastery', location: 'Sohag, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Sohag. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Beni Hasan Tombs', location: 'Minya, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Minya. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Tell el-Amarna', location: 'Minya, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Minya. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Tuna el-Gebel', location: 'Minya, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Minya. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Temple of Ramses II at Ashmunein', location: 'Minya, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in Minya. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Qasr Qarun', location: 'Fayoum, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Fayoum. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Hawara Pyramid', location: 'Fayoum, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Fayoum. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Wadi El Hitan', location: 'Fayoum, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Fayoum. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Meidum Pyramid', location: 'Beni Suef, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Beni Suef. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Port Said Military Museum', location: 'Port Said, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Port Said. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Ismailia Museum', location: 'Ismailia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Ismailia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Al-Arish Castle', location: 'North Sinai, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in North Sinai. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Saint Catherine’s Monastery', location: 'South Sinai, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in South Sinai. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Mons Claudianus', location: 'Red Sea, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Red Sea. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Temple of the Oracle at Siwa', location: 'Matrouh, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Matrouh. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Mountain of the Dead', location: 'Matrouh, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Matrouh. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Hibis Temple', location: 'New Valley, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in New Valley. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Deir el-Hagar Temple', location: 'New Valley, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Temples', description: 'Explore this heritage destination in New Valley. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Tell Basta Museum', location: 'Sharqia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Sharqia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Bubastis Archaeological Site', location: 'Sharqia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Sharqia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Rosetta Citadel', location: 'Beheira, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Beheira. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Mansoura National Museum', location: 'Dakahlia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Dakahlia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Kafr El Sheikh Museum', location: 'Kafr El Sheikh, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Kafr El Sheikh. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Tanta Museum', location: 'Gharbia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Gharbia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Denshway Museum', location: 'Monufia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Monufia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Meir Tombs', location: 'Assiut, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Assiut. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Suez National Museum', location: 'Suez, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Museums', description: 'Explore this heritage destination in Suez. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Amr Ibn Al-As Mosque, Damietta', location: 'Damietta, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Damietta. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
    HeritagePlace(name: 'Tell el-Yahudiya', location: 'Qalyubia, Egypt', image: 'assets/images/pyramids.png', rating: '—', price: 'Not available', category: 'Monuments', description: 'Explore this heritage destination in Qalyubia. Verified visitor details, entrance prices and opening times will be added with the full places dataset.'),
  ];

  static final List<HeritagePlace> all = List.unmodifiable([..._featured, ..._additional]);

  static const categories = ['All Sites', 'Museums', 'Temples', 'Mosques', 'Monuments'];

  String get governorate => location.split(',').first.trim();

  Map<String, dynamic> toMap() => {
        'name': name,
        'location': location,
        'image': image,
        'rating': rating,
        'price': price,
        'category': category,
        'description': description,
      };
}
