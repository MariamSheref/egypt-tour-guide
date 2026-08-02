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

  static const all = [
    HeritagePlace(
      name: 'Pyramids of Giza',
      location: 'Giza, Egypt',
      image: 'assets/images/pyramids.png',
      rating: '4.9',
      price: '300 EGP',
      category: 'History',
      description:
          'The Giza Necropolis stands as a testament to the architectural prowess of the Old Kingdom\'s Fourth Dynasty. As the only remaining wonder of the ancient world, these sandstone giants have witnessed four millennia of human history.',
    ),
    HeritagePlace(
      name: 'Karnak Temple',
      location: 'Luxor, Egypt',
      image: 'assets/images/karnak.jpg',
      rating: '4.8',
      price: '250 EGP',
      category: 'Architecture',
      description:
          'The Karnak Temple Complex is a vast open-air museum and the largest ancient religious site in the world. It was the most important place of worship in ancient Egypt for over 2,000 years.',
    ),
    HeritagePlace(
      name: 'Great Sphinx',
      location: 'Giza, Egypt',
      image: 'assets/images/sphinex.jpg',
      rating: '4.7',
      price: '200 EGP',
      category: 'History',
      description:
          'The Great Sphinx of Giza is a limestone statue of a reclining sphinx — a mythical creature with the head of a human and the body of a lion. It is the oldest known monumental sculpture in Egypt.',
    ),
    HeritagePlace(
      name: 'Abu Simbel',
      location: 'Aswan, Egypt',
      image: 'assets/images/karnak.jpg',
      rating: '4.9',
      price: '450 EGP',
      category: 'Culture',
      description:
          'Abu Simbel is an ancient temple complex carved into a mountainside during the reign of Pharaoh Ramesses II in the 13th century BCE. The temples were relocated in 1968 to avoid flooding from Lake Nasser.',
    ),
    HeritagePlace(
      name: 'Luxor Temple',
      location: 'Luxor, Egypt',
      image: 'assets/images/sphinex_close.jpg',
      rating: '4.6',
      price: '160 EGP',
      category: 'Architecture',
      description:
          'Luxor Temple is a large ancient Egyptian temple complex located on the east bank of the Nile River. Unlike other temples in the area, Luxor Temple is not dedicated to a cult deity or a deified pharaoh.',
    ),
  ];

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
