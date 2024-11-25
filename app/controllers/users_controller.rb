class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    # 1. जब user "/users/1" visit गर्छ, Rails यो action मा जान्छ
    # 2. params[:id] ले URL बाट "1" राख्छ
    @user = User.find(params[:id])

    # 3. Profile हेर्ने user को आधारमा map का लागि markers बनाउनुहोस्
    @markers = case @user.position
    when "Donneur-d'ordre"
      # 4a. यदि contractor ले आफ्नो profile हेर्दै छ भने:
      # - Database का सबै subcontractors खोज्नुहोस्
      # - .geocoded ले सुनिश्चित गर्छ valid lat/long भएका users मात्रै आउँछ
      # - .map ले प्रत्येक subcontractor लाई marker मा बदल्छ
      User.where(position: "Sous-traitant").geocoded.map do |user|
        create_marker(user)
      end
    when "Sous-traitant"
      # 4b. यदि subcontractor ले आफ्नो profile हेर्दै छ भने:
      # - सबै contractors खोज्नुहोस्
      # - उस्तै process: geocoded users पाउनुहोस् र markers बनाउनुहोस्
      User.where(position: "Donneur-d'ordre").geocoded.map do |user|
        create_marker(user)
      end
    else
      # 4c. यदि position invalid छ भने, खाली array फिर्ता गर्नुहोस् (कुनै marker हुँदैन)
      []
    end
  end

  private

  def set_user
    # यो method before_action ले show भन्दा अगाडि call गर्छ
    # सुनिश्चित गर्छ कि @user set गरिएको छ कुनै action को लागि जसलाई यसको आवश्यकता छ
    @user = User.find(params[:id])
  end

  def create_marker(user)
    # Hash बनाउनुहोस् जसलाई Mapbox JS ले markers राख्न प्रयोग गर्छ
    {
      # Geocoder gem ले user को coordinates पाएको छ:
      # - जब user ले address थप्छ/अपडेट गर्छ, geocoder ले त्यसलाई lat/long मा बदल्छ
      # - यी user.latitude र user.longitude मा store गरिन्छ
      lat: user.latitude,
      lng: user.longitude,

      # Popup window को HTML बनाउनुहोस्:
      # 1. render_to_string ले Rails partial लाई HTML string मा convert गर्छ
      # 2. _user_popup.html.erb ले popup को design राख्छ
      # 3. locals: {user: user} ले user को data partial मा pass गर्छ
      # 4. Result HTML हो जुन Mapbox ले popup मा देखाउनेछ
      info_window_html: render_to_string(
        partial: "users/user_popup",
        locals: { user: user }
      ),

      # Marker image set गर्नुहोस्:
      # 1. जाँच गर्नुहोस् कि user ले logo upload गरेको छ कि छैन (user.logo.attached?)
      # 2. यदि हो भने: uploaded logo को URL generate गर्नुहोस् (rails_blob_url)
      # 3. यदि छैन भने: default logo image प्रयोग गर्नुहोस् (helpers.asset_url)
      # यो URL Mapbox ले custom marker icon देखाउन प्रयोग गर्नेछ
      image_url: user.logo.attached? ?
        rails_blob_url(user.logo) :
        helpers.asset_url("default_logo.png")
    }
  end
end
