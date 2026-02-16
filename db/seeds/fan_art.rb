# frozen_string_literal: true

# Seed fan art data
fan_art_data = [
  {
    title: "Well Hello There",
    image_url: "https://nixten.ddns.net:9001/data/assets/index/fan-art/114ae387db40bf9f1cb615a7b1ec1baa339f0bd0ec4cd1d702a4da467e807259.png",
    artist_name: "DI_N_K0",
    artist_url: "https://l3v14th4n.straw.page/",
    featured: true
  },
  {
    title: "Flying High",
    image_url: "https://nixten.ddns.net:9001/data/assets/index/fan-art/facf5b3f3d413b7414429cca2ef3b2ce97c34f45.png",
    artist_name: "Barley",
    artist_url: "https://nixten.ddns.net/user/DoodlePaw",
    featured: false
  }
]

fan_art_data.each do |data|
  FanArt.find_or_create_by(title: data[:title]) do |fan_art|
    fan_art.image_url = data[:image_url]
    fan_art.artist_name = data[:artist_name]
    fan_art.artist_url = data[:artist_url]
    fan_art.featured = data[:featured]
  end
end

puts "Seeded #{FanArt.count} fan art items"
