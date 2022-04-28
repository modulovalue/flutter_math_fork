// TODO(adamjcook): Add library description.
library katex.font_metrics;


num sigma1 = 0.025;
num sigma2 = 0;
num sigma3 = 0;
num sigma4 = 0;
num sigma5 = 0.431;
num sigma6 = 1;
num sigma7 = 0;
num sigma8 = 0.677;
num sigma9 = 0.394;
num sigma10 = 0.444;
num sigma11 = 0.686;
num sigma12 = 0.345;
num sigma13 = 0.413;
num sigma14 = 0.363;
num sigma15 = 0.289;
num sigma16 = 0.150;
num sigma17 = 0.247;
num sigma18 = 0.386;
num sigma19 = 0.050;
num sigma20 = 2.390;
num sigma21 = 0.101;
num sigma22 = 0.250;

num xi1 = 0;
num xi2 = 0;
num xi3 = 0;
num xi4 = 0;
num xi5 = .431;
num xi6 = 1;
num xi7 = 0;
num xi8 = .04;
num xi9 = .111;
num xi10 = .166;
num xi11 = .2;
num xi12 = .6;
num xi13 = .1;

num ptPerEm = 10.0;

Map<String, num> metrics = {
	'xHeight': sigma5,
	'quad': sigma6,
    'num1': sigma8,
    'num2': sigma9,
    'num3': sigma10,
    'denom1': sigma11,
    'denom2': sigma12,
    'sup1': sigma13,
    'sup2': sigma14,
    'sup3': sigma15,
    'sub1': sigma16,
    'sub2': sigma17,
    'supDrop': sigma18,
    'subDrop': sigma19,
    'delim1': sigma20,
    'delim2': sigma21,
    'axisHeight': sigma22,
    'defaultRuleThickness': xi8,
    'bigOpSpacing1': xi9,
    'bigOpSpacing2': xi10,
    'bigOpSpacing3': xi11,
    'bigOpSpacing4': xi12,
    'bigOpSpacing5': xi13,
    'ptPerEm': ptPerEm
};

Map<String, Map<String, Map<String, num>>> metricMap = {
    "AMS-Regular": {
        "10003": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "10016": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "1008": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.04028,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "10731": {
            "depth": 0.11111,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "10846": {
            "depth": 0.19444,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "10877": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "10878": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "10885": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "10886": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "10887": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "10888": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "10889": {
            "depth": 0.26167,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10890": {
            "depth": 0.26167,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10891": {
            "depth": 0.48256,
            "height": 0.98256,
            "italic": 0.0,
            "skew": 0.0
        },
        "10892": {
            "depth": 0.48256,
            "height": 0.98256,
            "italic": 0.0,
            "skew": 0.0
        },
        "10901": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "10902": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "10933": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10934": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10935": {
            "depth": 0.26167,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10936": {
            "depth": 0.26167,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10937": {
            "depth": 0.26167,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10938": {
            "depth": 0.26167,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "10949": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "10950": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "10955": {
            "depth": 0.28481,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "10956": {
            "depth": 0.28481,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "165": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.025,
            "skew": 0.0
        },
        "174": {
            "depth": 0.15559,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "240": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "295": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "57350": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "57351": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "57352": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "57353": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.04028,
            "skew": 0.0
        },
        "57356": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "57357": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "57358": {
            "depth": 0.41951,
            "height": 0.91951,
            "italic": 0.0,
            "skew": 0.0
        },
        "57359": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "57360": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "57361": {
            "depth": 0.41951,
            "height": 0.91951,
            "italic": 0.0,
            "skew": 0.0
        },
        "57366": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "57367": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "57368": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "57369": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "57370": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "57371": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "65": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "66": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "67": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "68": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "69": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "70": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "71": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "72": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "73": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.9,
            "italic": 0.0,
            "skew": 0.0
        },
        "74": {
            "depth": 0.16667,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "75": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "76": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "77": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.9,
            "italic": 0.0,
            "skew": 0.0
        },
        "78": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "79": {
            "depth": 0.16667,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "80": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "81": {
            "depth": 0.16667,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "82": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8245": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "83": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "84": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8463": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8487": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8498": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "85": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8502": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8503": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8504": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8513": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8592": {
            "depth": -0.03598,
            "height": 0.46402,
            "italic": 0.0,
            "skew": 0.0
        },
        "8594": {
            "depth": -0.03598,
            "height": 0.46402,
            "italic": 0.0,
            "skew": 0.0
        },
        "86": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8602": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8603": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8606": {
            "depth": 0.01354,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8608": {
            "depth": 0.01354,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8610": {
            "depth": 0.01354,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8611": {
            "depth": 0.01354,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8619": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8620": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8621": {
            "depth": -0.13313,
            "height": 0.37788,
            "italic": 0.0,
            "skew": 0.0
        },
        "8622": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8624": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8625": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8630": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "8631": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "8634": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8635": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8638": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8639": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8642": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8643": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8644": {
            "depth": 0.1808,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8646": {
            "depth": 0.1808,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8647": {
            "depth": 0.1808,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8648": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8649": {
            "depth": 0.1808,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8650": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8651": {
            "depth": 0.01354,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8652": {
            "depth": 0.01354,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8653": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8654": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8655": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8666": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8667": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8669": {
            "depth": -0.13313,
            "height": 0.37788,
            "italic": 0.0,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8705": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "8708": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8709": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8717": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "8722": {
            "depth": -0.03598,
            "height": 0.46402,
            "italic": 0.0,
            "skew": 0.0
        },
        "8724": {
            "depth": 0.08198,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8726": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8733": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8736": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8737": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8738": {
            "depth": 0.03517,
            "height": 0.52239,
            "italic": 0.0,
            "skew": 0.0
        },
        "8739": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8740": {
            "depth": 0.25142,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8741": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8742": {
            "depth": 0.25142,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8756": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8757": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8764": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8765": {
            "depth": -0.13313,
            "height": 0.37788,
            "italic": 0.0,
            "skew": 0.0
        },
        "8769": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8770": {
            "depth": -0.03625,
            "height": 0.46375,
            "italic": 0.0,
            "skew": 0.0
        },
        "8774": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8776": {
            "depth": -0.01688,
            "height": 0.48312,
            "italic": 0.0,
            "skew": 0.0
        },
        "8778": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8782": {
            "depth": 0.06062,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8783": {
            "depth": 0.06062,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8785": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8786": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8787": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8790": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8791": {
            "depth": 0.22958,
            "height": 0.72958,
            "italic": 0.0,
            "skew": 0.0
        },
        "8796": {
            "depth": 0.08198,
            "height": 0.91667,
            "italic": 0.0,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8806": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "8807": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "8808": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "8809": {
            "depth": 0.25142,
            "height": 0.75726,
            "italic": 0.0,
            "skew": 0.0
        },
        "8812": {
            "depth": 0.25583,
            "height": 0.75583,
            "italic": 0.0,
            "skew": 0.0
        },
        "8814": {
            "depth": 0.20576,
            "height": 0.70576,
            "italic": 0.0,
            "skew": 0.0
        },
        "8815": {
            "depth": 0.20576,
            "height": 0.70576,
            "italic": 0.0,
            "skew": 0.0
        },
        "8816": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8817": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8818": {
            "depth": 0.22958,
            "height": 0.72958,
            "italic": 0.0,
            "skew": 0.0
        },
        "8819": {
            "depth": 0.22958,
            "height": 0.72958,
            "italic": 0.0,
            "skew": 0.0
        },
        "8822": {
            "depth": 0.1808,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8823": {
            "depth": 0.1808,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8828": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8829": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8830": {
            "depth": 0.22958,
            "height": 0.72958,
            "italic": 0.0,
            "skew": 0.0
        },
        "8831": {
            "depth": 0.22958,
            "height": 0.72958,
            "italic": 0.0,
            "skew": 0.0
        },
        "8832": {
            "depth": 0.20576,
            "height": 0.70576,
            "italic": 0.0,
            "skew": 0.0
        },
        "8833": {
            "depth": 0.20576,
            "height": 0.70576,
            "italic": 0.0,
            "skew": 0.0
        },
        "8840": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8841": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8842": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8843": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8847": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8848": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8858": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8859": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8861": {
            "depth": 0.08198,
            "height": 0.58198,
            "italic": 0.0,
            "skew": 0.0
        },
        "8862": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8863": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8864": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8865": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "8872": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8873": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8874": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8876": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8877": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8878": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8879": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8882": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8883": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8884": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8885": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8888": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8890": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "8891": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8892": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "89": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8901": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8903": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8905": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8906": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        },
        "8907": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8908": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8909": {
            "depth": -0.03598,
            "height": 0.46402,
            "italic": 0.0,
            "skew": 0.0
        },
        "8910": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8911": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8912": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8913": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8914": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8915": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8916": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8918": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8919": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8920": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8921": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "8922": {
            "depth": 0.38569,
            "height": 0.88569,
            "italic": 0.0,
            "skew": 0.0
        },
        "8923": {
            "depth": 0.38569,
            "height": 0.88569,
            "italic": 0.0,
            "skew": 0.0
        },
        "8926": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8927": {
            "depth": 0.13667,
            "height": 0.63667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8928": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8929": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8934": {
            "depth": 0.23222,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8935": {
            "depth": 0.23222,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8936": {
            "depth": 0.23222,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8937": {
            "depth": 0.23222,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8938": {
            "depth": 0.20576,
            "height": 0.70576,
            "italic": 0.0,
            "skew": 0.0
        },
        "8939": {
            "depth": 0.20576,
            "height": 0.70576,
            "italic": 0.0,
            "skew": 0.0
        },
        "8940": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8941": {
            "depth": 0.30274,
            "height": 0.79383,
            "italic": 0.0,
            "skew": 0.0
        },
        "8994": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8995": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "9416": {
            "depth": 0.15559,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "9484": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "9488": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "9492": {
            "depth": 0.0,
            "height": 0.37788,
            "italic": 0.0,
            "skew": 0.0
        },
        "9496": {
            "depth": 0.0,
            "height": 0.37788,
            "italic": 0.0,
            "skew": 0.0
        },
        "9585": {
            "depth": 0.19444,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "9586": {
            "depth": 0.19444,
            "height": 0.74111,
            "italic": 0.0,
            "skew": 0.0
        },
        "9632": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "9633": {
            "depth": 0.0,
            "height": 0.675,
            "italic": 0.0,
            "skew": 0.0
        },
        "9650": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "9651": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "9654": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "9660": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "9661": {
            "depth": 0.0,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "9664": {
            "depth": 0.03517,
            "height": 0.54986,
            "italic": 0.0,
            "skew": 0.0
        },
        "9674": {
            "depth": 0.11111,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "9733": {
            "depth": 0.19444,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "989": {
            "depth": 0.08167,
            "height": 0.58167,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Main-Bold": {
        "100": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "101": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "102": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.10903,
            "skew": 0.0
        },
        "10216": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10217": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "103": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.01597,
            "skew": 0.0
        },
        "104": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "105": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "106": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "108": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "10815": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "109": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "10927": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "10928": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "110": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "111": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "112": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "113": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "114": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "115": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "116": {
            "depth": 0.0,
            "height": 0.63492,
            "italic": 0.0,
            "skew": 0.0
        },
        "117": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "118": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.01597,
            "skew": 0.0
        },
        "119": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.01597,
            "skew": 0.0
        },
        "120": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "121": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.01597,
            "skew": 0.0
        },
        "122": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "123": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "124": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "125": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "126": {
            "depth": 0.35,
            "height": 0.34444,
            "italic": 0.0,
            "skew": 0.0
        },
        "168": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "172": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "175": {
            "depth": 0.0,
            "height": 0.59611,
            "italic": 0.0,
            "skew": 0.0
        },
        "176": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "177": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "180": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "215": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "247": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "305": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "33": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "34": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "35": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "36": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "37": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "38": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "39": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "40": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "41": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "42": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "43": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "44": {
            "depth": 0.19444,
            "height": 0.15556,
            "italic": 0.0,
            "skew": 0.0
        },
        "45": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "46": {
            "depth": 0.0,
            "height": 0.15556,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "48": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "49": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "50": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "51": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "52": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "53": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "54": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "55": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "56": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "567": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "57": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "58": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "59": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "60": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "61": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "62": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "63": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "64": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "65": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "66": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "67": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "68": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "69": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "70": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "71": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "711": {
            "depth": 0.0,
            "height": 0.63194,
            "italic": 0.0,
            "skew": 0.0
        },
        "713": {
            "depth": 0.0,
            "height": 0.59611,
            "italic": 0.0,
            "skew": 0.0
        },
        "714": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "715": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "72": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "728": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "729": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "73": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "730": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "74": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "75": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "76": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "768": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "769": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "77": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "772": {
            "depth": 0.0,
            "height": 0.59611,
            "italic": 0.0,
            "skew": 0.0
        },
        "774": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "775": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "776": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "778": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "779": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "78": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "780": {
            "depth": 0.0,
            "height": 0.63194,
            "italic": 0.0,
            "skew": 0.0
        },
        "79": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "80": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "81": {
            "depth": 0.19444,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "82": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "8211": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03194,
            "skew": 0.0
        },
        "8212": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03194,
            "skew": 0.0
        },
        "8216": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8217": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8220": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8221": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8224": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8225": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "824": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8242": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "83": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "84": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "8407": {
            "depth": 0.0,
            "height": 0.72444,
            "italic": 0.15486,
            "skew": 0.0
        },
        "8463": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8465": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8467": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8472": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8476": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "85": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "8501": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8592": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8593": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8594": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8595": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8596": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8597": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8598": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8599": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "86": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.01597,
            "skew": 0.0
        },
        "8600": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8601": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8636": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8637": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8640": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8641": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8656": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8657": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8658": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8659": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8660": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8661": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.01597,
            "skew": 0.0
        },
        "8704": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8706": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.06389,
            "skew": 0.0
        },
        "8707": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8709": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8711": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "8712": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8715": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8722": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8723": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8725": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8726": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8727": {
            "depth": -0.02778,
            "height": 0.47222,
            "italic": 0.0,
            "skew": 0.0
        },
        "8728": {
            "depth": -0.02639,
            "height": 0.47361,
            "italic": 0.0,
            "skew": 0.0
        },
        "8729": {
            "depth": -0.02639,
            "height": 0.47361,
            "italic": 0.0,
            "skew": 0.0
        },
        "8730": {
            "depth": 0.18,
            "height": 0.82,
            "italic": 0.0,
            "skew": 0.0
        },
        "8733": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8734": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8736": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8739": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8741": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8743": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8744": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8745": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8746": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8747": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.12778,
            "skew": 0.0
        },
        "8764": {
            "depth": -0.10889,
            "height": 0.39111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8768": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8771": {
            "depth": 0.00222,
            "height": 0.50222,
            "italic": 0.0,
            "skew": 0.0
        },
        "8776": {
            "depth": 0.02444,
            "height": 0.52444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8781": {
            "depth": 0.00222,
            "height": 0.50222,
            "italic": 0.0,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "8801": {
            "depth": 0.00222,
            "height": 0.50222,
            "italic": 0.0,
            "skew": 0.0
        },
        "8804": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8805": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8810": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8811": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8826": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8827": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8834": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8835": {
            "depth": 0.08556,
            "height": 0.58556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8838": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8839": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8846": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8849": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8850": {
            "depth": 0.19667,
            "height": 0.69667,
            "italic": 0.0,
            "skew": 0.0
        },
        "8851": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8852": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8853": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8854": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8855": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8856": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8857": {
            "depth": 0.13333,
            "height": 0.63333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8866": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8867": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8868": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8869": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "89": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.02875,
            "skew": 0.0
        },
        "8900": {
            "depth": -0.02639,
            "height": 0.47361,
            "italic": 0.0,
            "skew": 0.0
        },
        "8901": {
            "depth": -0.02639,
            "height": 0.47361,
            "italic": 0.0,
            "skew": 0.0
        },
        "8902": {
            "depth": -0.02778,
            "height": 0.47222,
            "italic": 0.0,
            "skew": 0.0
        },
        "8968": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8969": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8970": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8971": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8994": {
            "depth": -0.13889,
            "height": 0.36111,
            "italic": 0.0,
            "skew": 0.0
        },
        "8995": {
            "depth": -0.13889,
            "height": 0.36111,
            "italic": 0.0,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "91": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "915": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "916": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "92": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "920": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "923": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "926": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "928": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "93": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "931": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "933": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "934": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "936": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "937": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "94": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "95": {
            "depth": 0.31,
            "height": 0.13444,
            "italic": 0.03194,
            "skew": 0.0
        },
        "96": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9651": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9657": {
            "depth": -0.02778,
            "height": 0.47222,
            "italic": 0.0,
            "skew": 0.0
        },
        "9661": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9667": {
            "depth": -0.02778,
            "height": 0.47222,
            "italic": 0.0,
            "skew": 0.0
        },
        "97": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9711": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "98": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9824": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9825": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9826": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9827": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9837": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "9838": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9839": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "99": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Main-Italic": {
        "100": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.10333,
            "skew": 0.0
        },
        "101": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.07514,
            "skew": 0.0
        },
        "102": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.21194,
            "skew": 0.0
        },
        "103": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.08847,
            "skew": 0.0
        },
        "104": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.07671,
            "skew": 0.0
        },
        "105": {
            "depth": 0.0,
            "height": 0.65536,
            "italic": 0.1019,
            "skew": 0.0
        },
        "106": {
            "depth": 0.19444,
            "height": 0.65536,
            "italic": 0.14467,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.10764,
            "skew": 0.0
        },
        "108": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.10333,
            "skew": 0.0
        },
        "109": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.07671,
            "skew": 0.0
        },
        "110": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.07671,
            "skew": 0.0
        },
        "111": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.06312,
            "skew": 0.0
        },
        "112": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.06312,
            "skew": 0.0
        },
        "113": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.08847,
            "skew": 0.0
        },
        "114": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.10764,
            "skew": 0.0
        },
        "115": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.08208,
            "skew": 0.0
        },
        "116": {
            "depth": 0.0,
            "height": 0.61508,
            "italic": 0.09486,
            "skew": 0.0
        },
        "117": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.07671,
            "skew": 0.0
        },
        "118": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.10764,
            "skew": 0.0
        },
        "119": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.10764,
            "skew": 0.0
        },
        "120": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.12042,
            "skew": 0.0
        },
        "121": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.08847,
            "skew": 0.0
        },
        "122": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.12292,
            "skew": 0.0
        },
        "126": {
            "depth": 0.35,
            "height": 0.31786,
            "italic": 0.11585,
            "skew": 0.0
        },
        "163": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "305": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.07671,
            "skew": 0.0
        },
        "33": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.12417,
            "skew": 0.0
        },
        "34": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.06961,
            "skew": 0.0
        },
        "35": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.06616,
            "skew": 0.0
        },
        "37": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.13639,
            "skew": 0.0
        },
        "38": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.09694,
            "skew": 0.0
        },
        "39": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.12417,
            "skew": 0.0
        },
        "40": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.16194,
            "skew": 0.0
        },
        "41": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.03694,
            "skew": 0.0
        },
        "42": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.14917,
            "skew": 0.0
        },
        "43": {
            "depth": 0.05667,
            "height": 0.56167,
            "italic": 0.03694,
            "skew": 0.0
        },
        "44": {
            "depth": 0.19444,
            "height": 0.10556,
            "italic": 0.0,
            "skew": 0.0
        },
        "45": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02826,
            "skew": 0.0
        },
        "46": {
            "depth": 0.0,
            "height": 0.10556,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.16194,
            "skew": 0.0
        },
        "48": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "49": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "50": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "51": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "52": {
            "depth": 0.19444,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "53": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "54": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "55": {
            "depth": 0.19444,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "56": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "567": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03736,
            "skew": 0.0
        },
        "57": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.13556,
            "skew": 0.0
        },
        "58": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0582,
            "skew": 0.0
        },
        "59": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0582,
            "skew": 0.0
        },
        "61": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.06616,
            "skew": 0.0
        },
        "63": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.1225,
            "skew": 0.0
        },
        "64": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.09597,
            "skew": 0.0
        },
        "65": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "66": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10257,
            "skew": 0.0
        },
        "67": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.14528,
            "skew": 0.0
        },
        "68": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.09403,
            "skew": 0.0
        },
        "69": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.12028,
            "skew": 0.0
        },
        "70": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13305,
            "skew": 0.0
        },
        "71": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.08722,
            "skew": 0.0
        },
        "72": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.16389,
            "skew": 0.0
        },
        "73": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.15806,
            "skew": 0.0
        },
        "74": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.14028,
            "skew": 0.0
        },
        "75": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.14528,
            "skew": 0.0
        },
        "76": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "768": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "769": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.09694,
            "skew": 0.0
        },
        "77": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.16389,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.06646,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.11585,
            "skew": 0.0
        },
        "772": {
            "depth": 0.0,
            "height": 0.56167,
            "italic": 0.10333,
            "skew": 0.0
        },
        "774": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.10806,
            "skew": 0.0
        },
        "775": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.11752,
            "skew": 0.0
        },
        "776": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.10474,
            "skew": 0.0
        },
        "778": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "779": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.1225,
            "skew": 0.0
        },
        "78": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.16389,
            "skew": 0.0
        },
        "780": {
            "depth": 0.0,
            "height": 0.62847,
            "italic": 0.08295,
            "skew": 0.0
        },
        "79": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.09403,
            "skew": 0.0
        },
        "80": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10257,
            "skew": 0.0
        },
        "81": {
            "depth": 0.19444,
            "height": 0.68333,
            "italic": 0.09403,
            "skew": 0.0
        },
        "82": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.03868,
            "skew": 0.0
        },
        "8211": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.09208,
            "skew": 0.0
        },
        "8212": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.09208,
            "skew": 0.0
        },
        "8216": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.12417,
            "skew": 0.0
        },
        "8217": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.12417,
            "skew": 0.0
        },
        "8220": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.1685,
            "skew": 0.0
        },
        "8221": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.06961,
            "skew": 0.0
        },
        "83": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.11972,
            "skew": 0.0
        },
        "84": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13305,
            "skew": 0.0
        },
        "8463": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "85": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.16389,
            "skew": 0.0
        },
        "86": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.18361,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.18361,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.15806,
            "skew": 0.0
        },
        "89": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.19383,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.14528,
            "skew": 0.0
        },
        "91": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.1875,
            "skew": 0.0
        },
        "915": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13305,
            "skew": 0.0
        },
        "916": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "920": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.09403,
            "skew": 0.0
        },
        "923": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "926": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.15294,
            "skew": 0.0
        },
        "928": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.16389,
            "skew": 0.0
        },
        "93": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.10528,
            "skew": 0.0
        },
        "931": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.12028,
            "skew": 0.0
        },
        "933": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.11111,
            "skew": 0.0
        },
        "934": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05986,
            "skew": 0.0
        },
        "936": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.11111,
            "skew": 0.0
        },
        "937": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10257,
            "skew": 0.0
        },
        "94": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.06646,
            "skew": 0.0
        },
        "95": {
            "depth": 0.31,
            "height": 0.12056,
            "italic": 0.09208,
            "skew": 0.0
        },
        "97": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.07671,
            "skew": 0.0
        },
        "98": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.06312,
            "skew": 0.0
        },
        "99": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.05653,
            "skew": 0.0
        }
    },
    "Main-Regular": {
        "32": {
            "depth": -0.0,
            "height": 0.0,
            "italic": 0,
            "skew": 0
        },
        "160": {
            "depth": -0.0,
            "height": 0.0,
            "italic": 0,
            "skew": 0
        },
        "8230": {
            "depth": -0.0,
            "height": 0.12,
            "italic": 0,
            "skew": 0
        },
        "8773": {
            "depth": -0.022,
            "height": 0.589,
            "italic": 0,
            "skew": 0
        },
        "8800": {
            "depth": 0.215,
            "height": 0.716,
            "italic": 0,
            "skew": 0
        },
        "8942": {
            "depth": 0.03,
            "height": 0.9,
            "italic": 0,
            "skew": 0
        },
        "8943": {
            "depth": -0.19,
            "height": 0.31,
            "italic": 0,
            "skew": 0
        },
        "8945": {
            "depth": -0.1,
            "height": 0.82,
            "italic": 0,
            "skew": 0
        },
        "100": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "101": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "102": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.07778,
            "skew": 0.0
        },
        "10216": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10217": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "103": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.01389,
            "skew": 0.0
        },
        "104": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "105": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "106": {
            "depth": 0.19444,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "108": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "10815": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "109": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "10927": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "10928": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "110": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "111": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "112": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "113": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "114": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "115": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "116": {
            "depth": 0.0,
            "height": 0.61508,
            "italic": 0.0,
            "skew": 0.0
        },
        "117": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "118": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.01389,
            "skew": 0.0
        },
        "119": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.01389,
            "skew": 0.0
        },
        "120": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "121": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.01389,
            "skew": 0.0
        },
        "122": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "123": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "124": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "125": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "126": {
            "depth": 0.35,
            "height": 0.31786,
            "italic": 0.0,
            "skew": 0.0
        },
        "168": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "172": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "175": {
            "depth": 0.0,
            "height": 0.56778,
            "italic": 0.0,
            "skew": 0.0
        },
        "176": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "177": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "180": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "215": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "247": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "305": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "33": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "34": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "35": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "36": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "37": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "38": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "39": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "40": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "41": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "42": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "43": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "44": {
            "depth": 0.19444,
            "height": 0.10556,
            "italic": 0.0,
            "skew": 0.0
        },
        "45": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "46": {
            "depth": 0.0,
            "height": 0.10556,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "48": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "49": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "50": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "51": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "52": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "53": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "54": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "55": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "56": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "567": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "57": {
            "depth": 0.0,
            "height": 0.64444,
            "italic": 0.0,
            "skew": 0.0
        },
        "58": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "59": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "60": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "61": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "62": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "63": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "64": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "65": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "66": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "67": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "68": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "69": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "70": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "71": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "711": {
            "depth": 0.0,
            "height": 0.62847,
            "italic": 0.0,
            "skew": 0.0
        },
        "713": {
            "depth": 0.0,
            "height": 0.56778,
            "italic": 0.0,
            "skew": 0.0
        },
        "714": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "715": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "72": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "728": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "729": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "73": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "730": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "74": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "75": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "76": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "768": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "769": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "77": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "772": {
            "depth": 0.0,
            "height": 0.56778,
            "italic": 0.0,
            "skew": 0.0
        },
        "774": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "775": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "776": {
            "depth": 0.0,
            "height": 0.66786,
            "italic": 0.0,
            "skew": 0.0
        },
        "778": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "779": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "78": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "780": {
            "depth": 0.0,
            "height": 0.62847,
            "italic": 0.0,
            "skew": 0.0
        },
        "79": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "80": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "81": {
            "depth": 0.19444,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "82": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8211": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02778,
            "skew": 0.0
        },
        "8212": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02778,
            "skew": 0.0
        },
        "8216": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8217": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8220": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8221": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8224": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8225": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "824": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8242": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "83": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "84": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8407": {
            "depth": 0.0,
            "height": 0.71444,
            "italic": 0.15382,
            "skew": 0.0
        },
        "8463": {
            "depth": 0.0,
            "height": 0.68889,
            "italic": 0.0,
            "skew": 0.0
        },
        "8465": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8467": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.11111
        },
        "8472": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.11111
        },
        "8476": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "85": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8501": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8592": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8593": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8594": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8595": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8596": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8597": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8598": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8599": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "86": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.01389,
            "skew": 0.0
        },
        "8600": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8601": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8636": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8637": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8640": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8641": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8656": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8657": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8658": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8659": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8660": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8661": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.01389,
            "skew": 0.0
        },
        "8704": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8706": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.05556,
            "skew": 0.08334
        },
        "8707": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8709": {
            "depth": 0.05556,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8711": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8712": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8715": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8722": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8723": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8725": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8726": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8727": {
            "depth": -0.03472,
            "height": 0.46528,
            "italic": 0.0,
            "skew": 0.0
        },
        "8728": {
            "depth": -0.05555,
            "height": 0.44445,
            "italic": 0.0,
            "skew": 0.0
        },
        "8729": {
            "depth": -0.05555,
            "height": 0.44445,
            "italic": 0.0,
            "skew": 0.0
        },
        "8730": {
            "depth": 0.2,
            "height": 0.8,
            "italic": 0.0,
            "skew": 0.0
        },
        "8733": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "8734": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "8736": {
            "depth": 0.0,
            "height": 0.69224,
            "italic": 0.0,
            "skew": 0.0
        },
        "8739": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8741": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8743": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8744": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8745": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8746": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8747": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.11111,
            "skew": 0.0
        },
        "8764": {
            "depth": -0.13313,
            "height": 0.36687,
            "italic": 0.0,
            "skew": 0.0
        },
        "8768": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8771": {
            "depth": -0.03625,
            "height": 0.46375,
            "italic": 0.0,
            "skew": 0.0
        },
        "8776": {
            "depth": -0.01688,
            "height": 0.48312,
            "italic": 0.0,
            "skew": 0.0
        },
        "8781": {
            "depth": -0.03625,
            "height": 0.46375,
            "italic": 0.0,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8801": {
            "depth": -0.03625,
            "height": 0.46375,
            "italic": 0.0,
            "skew": 0.0
        },
        "8804": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8805": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8810": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8811": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8826": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8827": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8834": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8835": {
            "depth": 0.0391,
            "height": 0.5391,
            "italic": 0.0,
            "skew": 0.0
        },
        "8838": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8839": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8846": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8849": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8850": {
            "depth": 0.13597,
            "height": 0.63597,
            "italic": 0.0,
            "skew": 0.0
        },
        "8851": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8852": {
            "depth": 0.0,
            "height": 0.55556,
            "italic": 0.0,
            "skew": 0.0
        },
        "8853": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8854": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8855": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8856": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8857": {
            "depth": 0.08333,
            "height": 0.58333,
            "italic": 0.0,
            "skew": 0.0
        },
        "8866": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8867": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8868": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "8869": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "89": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.025,
            "skew": 0.0
        },
        "8900": {
            "depth": -0.05555,
            "height": 0.44445,
            "italic": 0.0,
            "skew": 0.0
        },
        "8901": {
            "depth": -0.05555,
            "height": 0.44445,
            "italic": 0.0,
            "skew": 0.0
        },
        "8902": {
            "depth": -0.03472,
            "height": 0.46528,
            "italic": 0.0,
            "skew": 0.0
        },
        "8968": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8969": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8970": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8971": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8994": {
            "depth": -0.14236,
            "height": 0.35764,
            "italic": 0.0,
            "skew": 0.0
        },
        "8995": {
            "depth": -0.14236,
            "height": 0.35764,
            "italic": 0.0,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "91": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "915": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "916": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "92": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "920": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "923": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "926": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "928": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "93": {
            "depth": 0.25,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "931": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "933": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "934": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "936": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "937": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.0
        },
        "94": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "95": {
            "depth": 0.31,
            "height": 0.12056,
            "italic": 0.02778,
            "skew": 0.0
        },
        "96": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9651": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9657": {
            "depth": -0.03472,
            "height": 0.46528,
            "italic": 0.0,
            "skew": 0.0
        },
        "9661": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9667": {
            "depth": -0.03472,
            "height": 0.46528,
            "italic": 0.0,
            "skew": 0.0
        },
        "97": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "9711": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "98": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9824": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9825": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9826": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9827": {
            "depth": 0.12963,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9837": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "9838": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "9839": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "99": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Math-BoldItalic": {
        "100": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "1009": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "101": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "1013": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "102": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.11042,
            "skew": 0.0
        },
        "103": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "104": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "105": {
            "depth": 0.0,
            "height": 0.69326,
            "italic": 0.0,
            "skew": 0.0
        },
        "106": {
            "depth": 0.19444,
            "height": 0.69326,
            "italic": 0.0622,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.01852,
            "skew": 0.0
        },
        "108": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0088,
            "skew": 0.0
        },
        "109": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "110": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "111": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "112": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "113": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "114": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03194,
            "skew": 0.0
        },
        "115": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "116": {
            "depth": 0.0,
            "height": 0.63492,
            "italic": 0.0,
            "skew": 0.0
        },
        "117": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "118": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "119": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.02778,
            "skew": 0.0
        },
        "120": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "121": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "122": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.04213,
            "skew": 0.0
        },
        "47": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "65": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "66": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.04835,
            "skew": 0.0
        },
        "67": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.06979,
            "skew": 0.0
        },
        "68": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.03194,
            "skew": 0.0
        },
        "69": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.05451,
            "skew": 0.0
        },
        "70": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.15972,
            "skew": 0.0
        },
        "71": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "72": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.08229,
            "skew": 0.0
        },
        "73": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.07778,
            "skew": 0.0
        },
        "74": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.10069,
            "skew": 0.0
        },
        "75": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.06979,
            "skew": 0.0
        },
        "76": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "77": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.11424,
            "skew": 0.0
        },
        "78": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.11424,
            "skew": 0.0
        },
        "79": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.03194,
            "skew": 0.0
        },
        "80": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.15972,
            "skew": 0.0
        },
        "81": {
            "depth": 0.19444,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "82": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.00421,
            "skew": 0.0
        },
        "83": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.05382,
            "skew": 0.0
        },
        "84": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.15972,
            "skew": 0.0
        },
        "85": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.11424,
            "skew": 0.0
        },
        "86": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.25555,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.15972,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.07778,
            "skew": 0.0
        },
        "89": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.25555,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.06979,
            "skew": 0.0
        },
        "915": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.15972,
            "skew": 0.0
        },
        "916": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "920": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.03194,
            "skew": 0.0
        },
        "923": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "926": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.07458,
            "skew": 0.0
        },
        "928": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.08229,
            "skew": 0.0
        },
        "931": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.05451,
            "skew": 0.0
        },
        "933": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.15972,
            "skew": 0.0
        },
        "934": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.0,
            "skew": 0.0
        },
        "936": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.11653,
            "skew": 0.0
        },
        "937": {
            "depth": 0.0,
            "height": 0.68611,
            "italic": 0.04835,
            "skew": 0.0
        },
        "945": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "946": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.03403,
            "skew": 0.0
        },
        "947": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.06389,
            "skew": 0.0
        },
        "948": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.03819,
            "skew": 0.0
        },
        "949": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "950": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.06215,
            "skew": 0.0
        },
        "951": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "952": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.03194,
            "skew": 0.0
        },
        "953": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "954": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "955": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "956": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "957": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.06898,
            "skew": 0.0
        },
        "958": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.03021,
            "skew": 0.0
        },
        "959": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "960": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "961": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "962": {
            "depth": 0.09722,
            "height": 0.44444,
            "italic": 0.07917,
            "skew": 0.0
        },
        "963": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "964": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.13472,
            "skew": 0.0
        },
        "965": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "966": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "967": {
            "depth": 0.19444,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "968": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "969": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03704,
            "skew": 0.0
        },
        "97": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        },
        "977": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "98": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "981": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "982": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.03194,
            "skew": 0.0
        },
        "99": {
            "depth": 0.0,
            "height": 0.44444,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Math-Italic": {
        "100": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.16667
        },
        "1009": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "101": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "1013": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "102": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.10764,
            "skew": 0.16667
        },
        "103": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.02778
        },
        "104": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "105": {
            "depth": 0.0,
            "height": 0.65952,
            "italic": 0.0,
            "skew": 0.0
        },
        "106": {
            "depth": 0.19444,
            "height": 0.65952,
            "italic": 0.05724,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.03148,
            "skew": 0.0
        },
        "108": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.01968,
            "skew": 0.08334
        },
        "109": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "110": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "111": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "112": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "113": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.08334
        },
        "114": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02778,
            "skew": 0.05556
        },
        "115": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "116": {
            "depth": 0.0,
            "height": 0.61508,
            "italic": 0.0,
            "skew": 0.08334
        },
        "117": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "118": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.02778
        },
        "119": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02691,
            "skew": 0.08334
        },
        "120": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "121": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.05556
        },
        "122": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.04398,
            "skew": 0.05556
        },
        "47": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "65": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.13889
        },
        "66": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05017,
            "skew": 0.08334
        },
        "67": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07153,
            "skew": 0.08334
        },
        "68": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.02778,
            "skew": 0.05556
        },
        "69": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05764,
            "skew": 0.08334
        },
        "70": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "71": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.08334
        },
        "72": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.08125,
            "skew": 0.05556
        },
        "73": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07847,
            "skew": 0.11111
        },
        "74": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.09618,
            "skew": 0.16667
        },
        "75": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07153,
            "skew": 0.05556
        },
        "76": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.02778
        },
        "77": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10903,
            "skew": 0.08334
        },
        "78": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10903,
            "skew": 0.08334
        },
        "79": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.02778,
            "skew": 0.08334
        },
        "80": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "81": {
            "depth": 0.19444,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.08334
        },
        "82": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.00773,
            "skew": 0.08334
        },
        "83": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05764,
            "skew": 0.08334
        },
        "84": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "85": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10903,
            "skew": 0.02778
        },
        "86": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.22222,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07847,
            "skew": 0.08334
        },
        "89": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.22222,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07153,
            "skew": 0.08334
        },
        "915": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "916": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.16667
        },
        "920": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.02778,
            "skew": 0.08334
        },
        "923": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.16667
        },
        "926": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07569,
            "skew": 0.08334
        },
        "928": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.08125,
            "skew": 0.05556
        },
        "931": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05764,
            "skew": 0.08334
        },
        "933": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.05556
        },
        "934": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.08334
        },
        "936": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.11,
            "skew": 0.05556
        },
        "937": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05017,
            "skew": 0.08334
        },
        "945": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0037,
            "skew": 0.02778
        },
        "946": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.05278,
            "skew": 0.08334
        },
        "947": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.05556,
            "skew": 0.0
        },
        "948": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.03785,
            "skew": 0.05556
        },
        "949": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "950": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.07378,
            "skew": 0.08334
        },
        "951": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.05556
        },
        "952": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.02778,
            "skew": 0.08334
        },
        "953": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "954": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "955": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "956": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "957": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.06366,
            "skew": 0.02778
        },
        "958": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.04601,
            "skew": 0.11111
        },
        "959": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "960": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.0
        },
        "961": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "962": {
            "depth": 0.09722,
            "height": 0.43056,
            "italic": 0.07986,
            "skew": 0.08334
        },
        "963": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.0
        },
        "964": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.1132,
            "skew": 0.02778
        },
        "965": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.02778
        },
        "966": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "967": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "968": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.03588,
            "skew": 0.11111
        },
        "969": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.0
        },
        "97": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "977": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.08334
        },
        "98": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "981": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.08334
        },
        "982": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02778,
            "skew": 0.0
        },
        "99": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        }
    },
    "Math-Regular": {
        "100": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.16667
        },
        "1009": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "101": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "1013": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "102": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.10764,
            "skew": 0.16667
        },
        "103": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.02778
        },
        "104": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "105": {
            "depth": 0.0,
            "height": 0.65952,
            "italic": 0.0,
            "skew": 0.0
        },
        "106": {
            "depth": 0.19444,
            "height": 0.65952,
            "italic": 0.05724,
            "skew": 0.0
        },
        "107": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.03148,
            "skew": 0.0
        },
        "108": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.01968,
            "skew": 0.08334
        },
        "109": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "110": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "111": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "112": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "113": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.08334
        },
        "114": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02778,
            "skew": 0.05556
        },
        "115": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "116": {
            "depth": 0.0,
            "height": 0.61508,
            "italic": 0.0,
            "skew": 0.08334
        },
        "117": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "118": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.02778
        },
        "119": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02691,
            "skew": 0.08334
        },
        "120": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "121": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.05556
        },
        "122": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.04398,
            "skew": 0.05556
        },
        "65": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.13889
        },
        "66": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05017,
            "skew": 0.08334
        },
        "67": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07153,
            "skew": 0.08334
        },
        "68": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.02778,
            "skew": 0.05556
        },
        "69": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05764,
            "skew": 0.08334
        },
        "70": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "71": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.08334
        },
        "72": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.08125,
            "skew": 0.05556
        },
        "73": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07847,
            "skew": 0.11111
        },
        "74": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.09618,
            "skew": 0.16667
        },
        "75": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07153,
            "skew": 0.05556
        },
        "76": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.02778
        },
        "77": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10903,
            "skew": 0.08334
        },
        "78": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10903,
            "skew": 0.08334
        },
        "79": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.02778,
            "skew": 0.08334
        },
        "80": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "81": {
            "depth": 0.19444,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.08334
        },
        "82": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.00773,
            "skew": 0.08334
        },
        "83": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05764,
            "skew": 0.08334
        },
        "84": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "85": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.10903,
            "skew": 0.02778
        },
        "86": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.22222,
            "skew": 0.0
        },
        "87": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.0
        },
        "88": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07847,
            "skew": 0.08334
        },
        "89": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.22222,
            "skew": 0.0
        },
        "90": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07153,
            "skew": 0.08334
        },
        "915": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.08334
        },
        "916": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.16667
        },
        "920": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.02778,
            "skew": 0.08334
        },
        "923": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.16667
        },
        "926": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.07569,
            "skew": 0.08334
        },
        "928": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.08125,
            "skew": 0.05556
        },
        "931": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05764,
            "skew": 0.08334
        },
        "933": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.13889,
            "skew": 0.05556
        },
        "934": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.0,
            "skew": 0.08334
        },
        "936": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.11,
            "skew": 0.05556
        },
        "937": {
            "depth": 0.0,
            "height": 0.68333,
            "italic": 0.05017,
            "skew": 0.08334
        },
        "945": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0037,
            "skew": 0.02778
        },
        "946": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.05278,
            "skew": 0.08334
        },
        "947": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.05556,
            "skew": 0.0
        },
        "948": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.03785,
            "skew": 0.05556
        },
        "949": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "950": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.07378,
            "skew": 0.08334
        },
        "951": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.05556
        },
        "952": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.02778,
            "skew": 0.08334
        },
        "953": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "954": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "955": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "956": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.02778
        },
        "957": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.06366,
            "skew": 0.02778
        },
        "958": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.04601,
            "skew": 0.11111
        },
        "959": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "960": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.0
        },
        "961": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "962": {
            "depth": 0.09722,
            "height": 0.43056,
            "italic": 0.07986,
            "skew": 0.08334
        },
        "963": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.0
        },
        "964": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.1132,
            "skew": 0.02778
        },
        "965": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.02778
        },
        "966": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.08334
        },
        "967": {
            "depth": 0.19444,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        },
        "968": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.03588,
            "skew": 0.11111
        },
        "969": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.03588,
            "skew": 0.0
        },
        "97": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.0
        },
        "977": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.08334
        },
        "98": {
            "depth": 0.0,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.0
        },
        "981": {
            "depth": 0.19444,
            "height": 0.69444,
            "italic": 0.0,
            "skew": 0.08334
        },
        "982": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.02778,
            "skew": 0.0
        },
        "99": {
            "depth": 0.0,
            "height": 0.43056,
            "italic": 0.0,
            "skew": 0.05556
        }
    },
    "Size1-Regular": {
        "8748": {
            "depth": 0.306,
            "height": 0.805,
            "italic": 0.19445,
            "skew": 0.0
        },
        "8749": {
            "depth": 0.306,
            "height": 0.805,
            "italic": 0.19445,
            "skew": 0.0
        },
        "10216": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "10217": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "10752": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10753": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10754": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10756": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10758": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "123": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "125": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "40": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "41": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.72222,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.72222,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.72222,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.72222,
            "italic": 0.0,
            "skew": 0.0
        },
        "8214": {
            "depth": -0.00099,
            "height": 0.601,
            "italic": 0.0,
            "skew": 0.0
        },
        "8593": {
            "depth": 1e-05,
            "height": 0.6,
            "italic": 0.0,
            "skew": 0.0
        },
        "8595": {
            "depth": 1e-05,
            "height": 0.6,
            "italic": 0.0,
            "skew": 0.0
        },
        "8657": {
            "depth": 1e-05,
            "height": 0.6,
            "italic": 0.0,
            "skew": 0.0
        },
        "8659": {
            "depth": 1e-05,
            "height": 0.6,
            "italic": 0.0,
            "skew": 0.0
        },
        "8719": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8720": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8721": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8730": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "8739": {
            "depth": -0.00599,
            "height": 0.606,
            "italic": 0.0,
            "skew": 0.0
        },
        "8741": {
            "depth": -0.00599,
            "height": 0.606,
            "italic": 0.0,
            "skew": 0.0
        },
        "8747": {
            "depth": 0.30612,
            "height": 0.805,
            "italic": 0.19445,
            "skew": 0.0
        },
        "8750": {
            "depth": 0.30612,
            "height": 0.805,
            "italic": 0.19445,
            "skew": 0.0
        },
        "8896": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8897": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8898": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8899": {
            "depth": 0.25001,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8968": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "8969": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "8970": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "8971": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "91": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "9168": {
            "depth": -0.00099,
            "height": 0.601,
            "italic": 0.0,
            "skew": 0.0
        },
        "92": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        },
        "93": {
            "depth": 0.35001,
            "height": 0.85,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Size2-Regular": {
        "8748": {
            "depth": 0.862,
            "height": 1.36,
            "italic": 0.44445,
            "skew": 0.0
        },
        "8749": {
            "depth": 0.862,
            "height": 1.36,
            "italic": 0.44445,
            "skew": 0.0
        },
        "10216": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "10217": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "10752": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "10753": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "10754": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "10756": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "10758": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "123": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "125": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "40": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "41": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8719": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8720": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8721": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8730": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "8747": {
            "depth": 0.86225,
            "height": 1.36,
            "italic": 0.44445,
            "skew": 0.0
        },
        "8750": {
            "depth": 0.86225,
            "height": 1.36,
            "italic": 0.44445,
            "skew": 0.0
        },
        "8896": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8897": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8898": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8899": {
            "depth": 0.55001,
            "height": 1.05,
            "italic": 0.0,
            "skew": 0.0
        },
        "8968": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "8969": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "8970": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "8971": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "91": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "92": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "93": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Size3-Regular": {
        "10216": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "10217": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "123": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "125": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "40": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "41": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8730": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "8968": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "8969": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "8970": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "8971": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "91": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "92": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        },
        "93": {
            "depth": 0.95003,
            "height": 1.45,
            "italic": 0.0,
            "skew": 0.0
        }
    },
    "Size4-Regular": {
        "10216": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "10217": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "123": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "125": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "40": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "41": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "47": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "57344": {
            "depth": -0.00499,
            "height": 0.605,
            "italic": 0.0,
            "skew": 0.0
        },
        "57345": {
            "depth": -0.00499,
            "height": 0.605,
            "italic": 0.0,
            "skew": 0.0
        },
        "57680": {
            "depth": 0.0,
            "height": 0.12,
            "italic": 0.0,
            "skew": 0.0
        },
        "57681": {
            "depth": 0.0,
            "height": 0.12,
            "italic": 0.0,
            "skew": 0.0
        },
        "57682": {
            "depth": 0.0,
            "height": 0.12,
            "italic": 0.0,
            "skew": 0.0
        },
        "57683": {
            "depth": 0.0,
            "height": 0.12,
            "italic": 0.0,
            "skew": 0.0
        },
        "710": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "732": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "770": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "771": {
            "depth": 0.0,
            "height": 0.825,
            "italic": 0.0,
            "skew": 0.0
        },
        "8730": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8968": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8969": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8970": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "8971": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "91": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "9115": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9116": {
            "depth": 1e-05,
            "height": 0.6,
            "italic": 0.0,
            "skew": 0.0
        },
        "9117": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9118": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9119": {
            "depth": 1e-05,
            "height": 0.6,
            "italic": 0.0,
            "skew": 0.0
        },
        "9120": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9121": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9122": {
            "depth": -0.00099,
            "height": 0.601,
            "italic": 0.0,
            "skew": 0.0
        },
        "9123": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9124": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9125": {
            "depth": -0.00099,
            "height": 0.601,
            "italic": 0.0,
            "skew": 0.0
        },
        "9126": {
            "depth": 0.64502,
            "height": 1.155,
            "italic": 0.0,
            "skew": 0.0
        },
        "9127": {
            "depth": 1e-05,
            "height": 0.9,
            "italic": 0.0,
            "skew": 0.0
        },
        "9128": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "9129": {
            "depth": 0.90001,
            "height": 0.0,
            "italic": 0.0,
            "skew": 0.0
        },
        "9130": {
            "depth": 0.0,
            "height": 0.3,
            "italic": 0.0,
            "skew": 0.0
        },
        "9131": {
            "depth": 1e-05,
            "height": 0.9,
            "italic": 0.0,
            "skew": 0.0
        },
        "9132": {
            "depth": 0.65002,
            "height": 1.15,
            "italic": 0.0,
            "skew": 0.0
        },
        "9133": {
            "depth": 0.90001,
            "height": 0.0,
            "italic": 0.0,
            "skew": 0.0
        },
        "9143": {
            "depth": 0.88502,
            "height": 0.915,
            "italic": 0.0,
            "skew": 0.0
        },
        "92": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        },
        "93": {
            "depth": 1.25003,
            "height": 1.75,
            "italic": 0.0,
            "skew": 0.0
        }
    }
};


/**
 * Convience function for looking up information in the
 * metricMap table.
 */
Map<String, num> getCharacterMetrics ( { String character, String style } ) {

    return metricMap[ style ][ character.codeUnitAt(0).toString() ];
    
}