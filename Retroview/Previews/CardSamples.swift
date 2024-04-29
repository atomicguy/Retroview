//
//  CardSamples.swift
//  Retroview
//
//  Created by Adam Schuster on 4/8/24.
//

import Foundation

extension CardSchemaV1.StereoCard {
    static var sampleCards: [CardSchemaV1.StereoCard] {
        [
            CardSchemaV1.StereoCard(
                uuid: "c7980740-c53b-012f-c86d-58d385a7bc34",
                titles: [
                    TitleSchemaV1.Title(
                        text: "Bird's-eye view, Columbian Exposition."
                    ),
                    TitleSchemaV1.Title(text: "Stereoscopic views of the World's Columbian Exposition. 7972.")
                ],
                authors: [
                    AuthorSchemaV1.Author(
                        name: "Kilburn, B. W. (Benjamin West) (1827-1909)"
                    )
                ],
                subjects: [
                    SubjectSchemaV1.Subject(
                        name: "Chicago (Ill.)"
                    ),
                    SubjectSchemaV1.Subject(
                        name: "Illinois"
                    ),
                    SubjectSchemaV1.Subject(
                        name: "World's Columbian Exposition (1893 : Chicago, Ill.)"
                    ),
                    SubjectSchemaV1.Subject(
                        name: "Exhibitions"
                    )
                ],
                dates: [
                    DateSchemaV1.Date(
                        text: "1893"
                    )
                ],
                imageIdFront: "IMG123f",
                imageIdBack: "IMG123b",
                left: CropSchemaV1.Crop(
                    x0: 0.0,
                    y0: 0.0,
                    x1: 0.0,
                    y1: 0.0,
                    score: 0.9,
                    side: "left"
                ),
                right: CropSchemaV1.Crop(
                    x0: 0.0,
                    y0: 0.0,
                    x1: 0.0,
                    y1: 0.0,
                    score: 0.9,
                    side: "right"
                )
            ),
            CardSchemaV1.StereoCard(
                uuid: "f0bf5ba0-c53b-012f-dab2-58d385a7bc34",
                titles: [
                    TitleSchemaV1.Title(
                        text: "Stereoscopic views of the World's Columbian Exposition. 8288."
                    ),
                    TitleSchemaV1.Title(
                        text: "Ostrich farm, Midway Plaisance, Columbian Exposition."
                    )
                ],
                authors: [
                    AuthorSchemaV1.Author(
                        name: "Kilburn, B. W. (Benjamin West) (1827-1909)"
                    )
                ],
                subjects: [
                    SubjectSchemaV1.Subject(
                        name: "Chicago (Ill.)"
                    ),
                    SubjectSchemaV1.Subject(
                        name: "Illinois"
                    ),
                    SubjectSchemaV1.Subject(
                        name: "World's Columbian Exposition (1893 : Chicago, Ill.)"
                    ),
                    SubjectSchemaV1.Subject(
                        name: "Exhibitions"
                    )
                ],
                dates: [
                    DateSchemaV1.Date(
                        text: "1893"
                    )
                ],
                imageIdFront: "IMG321f",
                imageIdBack: "IMG321b",
                left: CropSchemaV1.Crop(
                    x0: 0.0,
                    y0: 0.0,
                    x1: 0.0,
                    y1: 0.0,
                    score: 0.9,
                    side: "left"
                ),
                right: CropSchemaV1.Crop(
                    x0: 0.0,
                    y0: 0.0,
                    x1: 0.0,
                    y1: 0.0,
                    score: 0.9,
                    side: "right"
                )
            ),
//            CardSchemaV1.StereoCard(
//                uuid: "ecea5fb0-c53b-012f-7f72-58d385a7bc34",
//                titles: [
//                    "Stereoscopic views of the World's Columbian Exposition. 8244.",
//                    "The great Ferris Wheel, Midway Plaisance, Columbian Exposition."
//                ],
//                authors: [
//                    "Kilburn, B. W. (Benjamin West) (1827-1909)"
//                ],
//                subjects: [
//                    "Chicago (Ill.)",
//                    "Illinois",
//                    "World's Columbian Exposition (1893 : Chicago, Ill.)",
//                    "Exhibitions"
//                ],
//                dates: [
//                    "1893"
//                ]
//            ),
//            CardSchemaV1.StereoCard(
//                uuid: "e5082480-c53b-012f-b6f2-58d385a7bc34",
//                titles: [
//                    "Idols of the British Columbian Indians, Columbian Exposition.",
//                    "Stereoscopic views of the World's Columbian Exposition. 8199."
//                ],
//                authors: [
//                    "Kilburn, B. W. (Benjamin West) (1827-1909)"
//                ],
//                subjects: [
//                    "Chicago (Ill.)",
//                    "Illinois",
//                    "World's Columbian Exposition (1893 : Chicago, Ill.)",
//                    "Exhibitions"
//                ],
//                dates: [
//                    "1893"
//                ]
//            ),
//            CardSchemaV1.StereoCard(
//                uuid: "e9b0f580-c53b-012f-54ac-58d385a7bc34",
//                titles: [
//                    "The convent where Columbus died, Columbian Exposition. 8228.",
//                    "This train made the quickest time on record, a mile in 32 seconds. Columbian Exposition."
//                ],
//                authors: [
//                    "Kilburn, B. W. (Benjamin West) (1827-1909)"
//                ],
//                subjects: [
//                    "Chicago (Ill.)",
//                    "Illinois",
//                    "World's Columbian Exposition (1893 : Chicago, Ill.)",
//                    "Exhibitions"
//                ],
//                dates: [
//                    "1893"
//                ]
//            ),
//            CardSchemaV1.StereoCard(
//                uuid: "d6661a90-c53b-012f-fcd1-58d385a7bc34",
//                titles: [
//                    "The crowning glory of the Basin, Columbian Exposition.",
//                    "Stereoscopic views of the World's Columbian Exposition. 8104."
//                ],
//                authors: [
//                    "Kilburn, B. W. (Benjamin West) (1827-1909)"
//                ],
//                subjects: [
//                    "Chicago (Ill.)",
//                    "Illinois",
//                    "World's Columbian Exposition (1893 : Chicago, Ill.)",
//                    "Exhibitions"
//                ],
//                dates: [
//                    "1893"
//                ]
//            )
        ]
    }
}
