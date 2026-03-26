import SwiftUI

struct About: View {
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: Coptic Church
                AboutSection(
                    imageName: "about",
                    title: "The Coptic Orthodox Church",
                    content: [
                        "The Coptic Church was established in the name of the Lord Jesus Christ by St. Mark the Evangelist in the city of Alexandria around 43 A.D. The church adheres to the Nicene Creed. St. Athanasius (296-373 A.D.), the twentieth Pope of the Coptic Church effectively defended the Doctrine of the Lord Jesus Christ's Divinity at the Council of Nicea in 325 A.D. His affirmation of the doctrine earned him the title; \"Father of Orthodoxy\" and St. Athanasius \"the Apostolic\".",
                        
                        "The term \"Coptic\" is derived from the Greek \"Aigyptos\" meaning \"Egyptian\". When the Arabs arrived in Egypt in the seventh century, they called the Egyptians \"qibt\". Thus the Arabic word \"qibt\" came to mean both \"Egyptians\" and \"Christians\".",
                        
                        "The term \"Orthodoxy\" here refers to the preservation of the \"Original Faith\" by the Copts who, throughout the ages, defended the Old Creed against the numerous attacks aimed at it.",
                        
                        "The Coptic Orthodox Church worships the Father, the Son and the Holy Spirit in the Oneness of Nature. We believe in One God; Father, Son and Holy Spirit » three equal Co-Essential and Co-Indwelling Hypostasis (Persons). The Blessed and Holy Trinity is our One God. We Believe that Lord Jesus Christ, the Only-Begotten of the Father and Who is One with Him in Essence is the only Savior of the world; we are Miaphysites; There is a difference between the »Monophysites» who believe in just One Single Nature (Divine) of Lord Jesus Christ and the »Miaphysites» who believe in One United Nature or One Composite Nature (Divine & Human) of Lord Jesus Christ. We do not believe in just a Single Nature but we do believe in the One Incarnate Nature of the Logos. Less changes have taken place in the Coptic Church than in any other church whether in the ritual or doctrine aspects and that the succession of the Coptic Patriarchs, Bishops, priests and Deacons has been continuous."
                    ],
                    fontSize: appFontSize
                )

                Divider()

                // MARK: St. Julitta
                AboutSection(
                    imageName: "SJ",
                    title: "St. Julitta Coptic Orthodox Church",
                    content: [
                        "The Coptic Orthodox community in Pearland, Texas was officially established on August 11, 2018 by His Eminence Metropolitan Youssef.",
                        
                        "On May 26, 2021, the community was able to purchase a 5 acre property in the heart of Pearland to call home and on June 2, 2021 was blessed to have His Grace Bishop Gregory pray the inaugural Thanksgiving prayer on the future church site.",
                        
                        "The first liturgy in the new church building was prayed on December 13, 2025 with Fr. Matthias Shehad, Fr. Tobia Manoli and Fr. Barnaba Melek.  The grand opening celebration of the church was presided over by His Grace Bishop Gregory and several Houston-area priests on January 3, 2026.",
                        
                        "On January 31, 2025, the St. Julitta community was officially elevated and became the 7th Coptic Orthodox Church in the Houston area with Fr. Barnaba Melek assigned to serve as its permanent priest.",
                        
                        "St. Julitta Coptic Orthodox Church belongs to the Coptic Orthodox Diocese of the Southern United States which is shepherded by His Eminence Metropolitan Youssef and includes all of the Coptic Orthodox churches in Alabama, Arizona, Arkansas, Florida, Georgia, Louisiana, Mississippi, New Mexico, Oklahoma, Tennessee and Texas."
                    ],
                    fontSize: appFontSize
                )

                Divider()

                // MARK: Pope Tawadros
                AboutSection(
                    imageName: "popetawadros",
                    title: "HH Pope Tawadros II",
                    content: [
                        "His Holiness Pope Tawadros II was born Wagih Sobhy Baky Soliman on November 4, 1952 in Mansoura. His father was an irrigation engineer and his family moved around during his childhood from Mansoura to Sohag and then to Damanhour.",
                        
                        "His Holiness was enthroned as the 118th Pope of Alexandria and Pope of the See of St. Mark on November 18, 2012 at the Cathedral of St. Rueiss in Abbassiya, Cairo. The enthronement was presided by H.E. Metropolitan Pakhomious of Beheira, other metropolitans and bishops of the Coptic church and was attended by many delegates of Christian Churches.",
                        
                        "We pray that the Lord will bless our beloved shepherd, H.H. Pope Tawadros II, protect him, and preserve his life and services for his children all over the world."
                    ],
                    fontSize: appFontSize
                )

                Divider()

                // MARK: Metropolitan Youssef
                AboutSection(
                    imageName: "metropolitanyoussef",
                    title: "HE Metropolitan Youssef",
                    content: [
                        "Listening to the call of the Lord Jesus Christ, His Eminence Metropolitan Youssef entered the monastic life in 1986 at the El-Souryan Monastery. He was ordained into the priesthood in 1988. Then in 1989, he came to the United States under the auspices of His Holiness Pope Shenouda III, the 117th Pope of the Holy See of St. Mark. He was appointed resident priest to serve the Coptic congregation of St. Mary Church in Dallas/Fort Worth.",
                        
                        "In 1992, His Grace was ordained as General Bishop and in 1993, His Grace was appointed to oversee the Southern Coptic Diocese. In 1995, His Grace was enthroned as the first Bishop of the Coptic Orthodox Diocese of the Southern United States. Then in 2022, His Grace was elevated to Metropolitan by His Holiness Pope Tawadros II, the 118th Pope of the Holy See of St. Mark."
                    ],
                    fontSize: appFontSize
                )

                Divider()

                // MARK: Bishop Gregory
                AboutSection(
                    imageName: "bishopgregory",
                    title: "HG Bishop Gregory",
                    content: [
                        "His Grace Bishop Gregory was born in Egypt and raised in Montreal, Canada until our Lord Jesus Christ called him to enter the monastic life in 2007. His Grace first entered the St. Antony Monastery in California in 2007 and then transferred to the St. Mary & St. Moses Abbey in Sandia, TX in 2009. He was consecrated a monk at St. Mary & St. Moses Abbey in Sandia, TX in 2011 and ordained into the priesthood in 2016. Then in 2017, His Eminence Metropolitan Youssef appointed him Episcopal Vicar for the states of Texas and Arizona. In 2018, His Grace was elevated to Hegumen and later that same year he was ordained as a General Bishop serving under the auspices of His Eminence Metropolitan Youssef in the Coptic Orthodox Diocese of the Southern United States."
                    ],
                    fontSize: appFontSize
                )

                Divider()

                // MARK: Fr. Barnaba
                AboutSection(
                    imageName: "frbernaba",
                    title: "Fr. Bernaba Melek",
                    content: [
                        "Fr. Barnaba Melek is the priest for St. Julitta Coptic Orthodox Church located in Pearland, TX. H.G. Bishop Youssef ordained him priest on December 3, 2017. He began his service in St. Philopateer Coptic Orthodox Church in Dallas, TX and then 2019-2021, he served in St. Mark Coptic Orthodox Church in Frisco, TX. From 2021-2026, he served in St. Antony Coptic Orthodox Church. Then in 2026, H.E. Metropolitan Youssef asked him to serve in St. Julitta Coptic Orthodox Church. Fr. Barnaba has been serving within the Diocese of the Southern United States since December 3, 2017. We pray that the Lord will continue blessing his service."
                    ],
                    fontSize: appFontSize
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("About")
                    .font(.system(size: appFontSize, weight: .semibold))
            }
        }
    }
}


// MARK: - Reusable Section Component

struct AboutSection: View {
    let imageName: String
    let title: String
    let content: [String]
    let fontSize: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Image centered
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)
                .frame(maxWidth: .infinity)

            // Title
            Text(title)
                .font(.system(size: fontSize + 6, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Paragraphs
            ForEach(content, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.system(size: fontSize))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
#Preview {
    About()
}
