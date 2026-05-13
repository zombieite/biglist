#!/usr/bin/env perl
use strict;
use warnings;
use GD::Barcode::QRcode;
use URI::Escape qw(uri_escape_utf8);
use File::Path  qw(make_path);
use File::Basename;
use Cwd qw(abs_path);
use Data::Dumper;

sub main {
    my $addresses = [
        { address => "Art Institute of Chicago, 111 S Michigan Ave, Chicago, IL 60603" },
        { address => "Cloud Gate, 201 E Randolph St, Chicago, IL 60602" },
        { address => "Historic Illinois US 66 Route Signage, E Adams St & S Michigan Ave, Chicago, IL" },
        { address => "Lou Mitchell's, 565 W Jackson Blvd, Chicago, IL 60661" },
        { address => "Lulu's Hot Dogs, 1000 S Leavitt St, Chicago, IL 60612" },
        { address => "Steak 'n Egger, 5647 Ogden Ave, Cicero, IL 60804" },
        { address => "Henry's Drive-In, 6031 Ogden Ave, Cicero, IL 60804" },
        { address => "Cigars & Stripes BBQ Lounge, 6715 Ogden Ave, Berwyn, IL 60402" },
        { address => "Dell Rhea's Chicken Basket, 645 Joliet Rd, Willowbrook, IL 60527" },
        { address => "White Fence Farm Restaurant, 1376 Joliet Rd, Romeoville, IL 60446" },
        { address => "The Beller Museum, 275 Rocbaar Dr, Romeoville, IL 60446" },
        { address => "Old Joliet Prison, 1125 Collins St, Joliet, IL 60432" },
        { address => "Joliet Area Historical Museum, 204 N Ottawa St, Joliet, IL 60432" },
        { address => "Rialto Square Theatre, 102 N Chicago St, Joliet, IL 60432" },
        { address => "Blues Brothers Copmobile, 2410 S Chicago St, Joliet, IL 60436" },
        { address => "Art on 66, 208 N Water St, Wilmington, IL 60481" },
        { address => "Gemini Giant, 201 Bridge St, Wilmington, IL 60481" },
        { address => "Polk-A-Dot Drive In, 222 N Front St, Braidwood, IL 60408" },
        { address => "The Shop on Route 66, 315 N Center St, Gardner, IL 60424" },
        { address => "80s Car Museum, 316 W Waupansie St, Dwight, IL 60420" },
        { address => "Gothic Church Dwight Townhall, 201 N Franklin St, Dwight, IL 60420" },
        { address => "Dwight Coin Laundry, 404 W Waupansie St, Dwight, IL 60420" },
        { address => "Ambler's Texaco Gas Station, W Waupansie St, Dwight, IL 60420" },
        { address => "Standard Oil Gas Station, 400 S West St, Odell, IL 60460" },
        { address => "Route 66 Association of Illinois, 110 W Howard St, Pontiac, IL 61764" },
        { address => "Pontiac Oakland Auto Museum, 205 N Mill St, Pontiac, IL 61764" },
        { address => "Wally's, 1 Holiday Rd, Pontiac, IL 61764" },
        { address => "Route 66 of Chenoa Roadside Attraction & Tourist Info, P7RC+C3, Chenoa IL 61726" },
        { address => "Lexington Route 66 Memory Lane, Parade Rd, Lexington, IL 61753" },
        { address => "The Shake Shack, 512 W Main St, Lexington, IL 61753" },
        { address => "Sprague's Super Service Station, 305 Pine St, Normal, IL 61761" },
        { address => "Carl's Ice Cream Factory, 1700 W College Ave, Normal, IL 61761" },
        { address => "Funks Grove Pure Maple Sirup Farm, Funks Grove Township, IL 61754" },
        { address => "Pinball Paradise, 102 E Morgan St, McLean, IL 61754" },
        { address => "Arcadia: America's Playable Arcade Museum, 107 S Hamilton St, McLean, IL 61754" },
        { address => "Country-Aire Restaurant, 606 E South St, Atlanta, IL 61723" },
        { address => "American Giants Museum, 100 SW St, Atlanta, IL 61723" },
        { address => "Hot Dog Muffler Man, 112 SW Arch St, Atlanta, IL 61723" },
        { address => "The Mill Museum on Route 66, 738 S Washington St, Lincoln, IL 62656" },
        { address => "Wild Hare Cafe, 104 Governor Oglesby St, Elkhart, IL 62634" },
        { address => "The Old Station, 117 Elm St, Williamsville, IL 62693" },
        { address => "Outkast Tattoo Studio, 2828 N Peoria Rd, Springfield, IL 62702" },
        { address => "Illinois State Fair Route 66 Experience, 801 E Sangamon Ave, Springfield, IL 62702" },
        { address => "Route 66 Hotel & Conference Center, 625 E St Joseph St, Springfield, IL 62703" },
        { address => "Shea's Filling Station, 2075 N Peoria Rd, Springfield, IL 62702" },
        { address => "Maid-Rite, 118 N Pasfield St, Springfield, IL 62702" },
        { address => "Pharmacy Gallery & Art Space, 623 E Adams St, Springfield, IL 62701" },
        { address => "Springfield Southeast High School, 2350 E Ash St, Springfield, IL 62703" },
        { address => "Mel-O-Cream Donuts, 217 E Laurel St, Springfield, IL 62704" },
        { address => "Ace Sign Co., 2540 S 1st St, Springfield, IL 62704" },
        { address => "Charlie Parker's Diner, 700 W North St, Springfield, IL 62704" },
        { address => "Lauterbach Muffler Man, 1569 Wabash Ave, Springfield, IL 62704" },
        { address => "Pinky Elephant with Martini, 2723 S 6th St, Springfield, IL 62703" },
        { address => "Cozy Dog, 2935 S 6th St, Springfield, IL 62703" },
        { address => "Curve Inn, 3219 S 6th St, Springfield, IL 62703" },
        { address => "Route 66 Motorheads Bar and Grill, 600 Toronto Rd, Springfield, IL 62711" },
        { address => "Sangamo Brewing, 109 E Mulberry St, Chatham, IL 62629" },
        { address => "Chatham Railroad Museum, 100 N State St, Chatham, IL 62629" },
        { address => "Illinois Brick Road, 4995–4790 Snell Rd, Auburn, IL 62615" },
        { address => "Sly Fox Bookstore, 123 N Springfield St, Virden, IL 62690" },
        { address => "Doc's Just Off 66, 133 S 2nd St, Girard, IL 62640" },
        { address => "Whirl A Whip, 309 S 3rd St, Girard, IL 62640" },
        { address => "Turkey Tracks on Route 66, 26618–27306 Donaldson Rd, Girard, IL 62640" },
        { address => "Carlinvilla Motel, 18891 State Rte 4, Carlinville, IL 62626" },
        { address => "Rt 66 Skyview Drive-In, 1500 Old Rte 66 N, Litchfield, IL 62056" },
        { address => "Niehaus Cycle Sales, 718 Old Rte 66 N, Litchfield, IL 62056" },
        { address => "The Ariston Cafe, 413 Old Rte 66 N, Litchfield, IL 62056" },
        { address => "Litchfield Museum & Route 66 Welcome Center, 334 Old Rte 66 N, Litchfield, IL 62056" },
        { address => "Soulsby Service Station, 710 W 1st St, Mt Olive, IL 62069" },
        { address => "Henry's Rabbit Ranch, 1107 Historic Old Rte 66, Staunton, IL 62088" },
        { address => "DeCamp Station, 8767 State Rte 4, Staunton, IL 62088" },
        { address => "Pink Elephant Antique Mall, 908 Veterans Memorial Dr, Livingston, IL 62058" },
        { address => "Route 66 Creamery, 11 S Old Rte 66, Hamel, IL 62046" },
        { address => "Weezy's, 108 Old Rte 66, Hamel, IL 62046" },
        { address => "Wildey Theatre, 252 N Main St, Edwardsville, IL 62025" },
        { address => "West End Service Station, 620 St Louis St, Edwardsville, IL 62025" },
        { address => "Luna Cafe, 201 E Chain of Rocks Rd, Granite City, IL 62040" },
        { address => "Old Chain of Rocks Bridge, 10820 Riverview Dr, St. Louis, MO 63137" },
        { address => "O'Brien Tire & Auto Care, 3924 Nameoki Rd, Granite City, IL 62040" },
        { address => "Mr. Twist Ice Cream, 2649 Madison Ave, Granite City, IL 62040" },
        { address => "It's Electric Neon Sign Park, 1300 19th St, Granite City, IL 62040" },
        { address => "614 Niedringhaus Ave, Granite City, IL 62040" },
        { address => "Crown Candy Kitchen, 1401 St Louis Ave, St. Louis, MO 63106" },
        { address => "Skate King Roller Rink, 2700 Kienlen Ave, St. Louis, MO 63121" },
        { address => "The Gateway Arch, St. Louis, MO 63102" },
        { address => "Neon Museum of St. Louis, 3537 Chouteau Ave, St. Louis, MO 63103" },
        { address => "Ted Drewes Frozen Custard, 6726 Chippewa St, St. Louis, MO 63109" },
        { address => "Wally's, 950 Assembly Pkwy, Fenton, MO 63026" },
        { address => "The Malt Shop, 1751 Smizer Station Rd, Fenton, MO 63026" },
        { address => "Route 66 State Park, 97 N Outer Rd, Eureka, MO 63025" },
        { address => "Campbell's Service, 18625 Historic Rte 66, Pacific, MO 63069" },
        { address => "Red Cedar Inn Museum and Visitor Center, 1047 E Osage St, Pacific, MO 63069" },
        { address => "2827 MO-100, Villa Ridge, MO 63089" },
        { address => "Old Sunset Motel, 976 Osage Villa Ct, Villa Ridge, MO 63089" },
        { address => "Creative Chainsaw Carvings, 151 State Rte W, Sullivan, MO 63080" },
        { address => "Meramec Caverns, 1135 Hwy W, Sullivan, MO 63080" },
        { address => "Shamrock Court Motel, 101 Shamrock, Sullivan, MO 63080" },
        { address => "Missouri Hick Barbeque, 913 E Washington Blvd, Cuba, MO 65453" },
        { address => "Wagon Wheel Motel, 901 E Washington Blvd, Cuba, MO 65453" },
        { address => "Weir on 66 / Rich's Famous Burgers, 102 W Washington St, Cuba, MO 65453" },
        { address => "Fanning Outpost Rocking Chair, 5957 State Hwy ZZ, Cuba, MO 65453" },
        { address => "Mule Trading Post, 11160 Dillon Outer Rd, Rolla, MO 65401" },
        { address => "John's Modern Cabins on Route 66, 11107 Arlington Outer Rd, Newburg, MO 65550" },
        { address => "Arlington, Arlington, MO 65550" },
        { address => "Devil's Elbow Bridge, Big Piney River, Devils Elbow, MO 65457" },
        { address => "Uranus Fudge Factory, 14400 State Hwy Z, St. Robert, MO 65584" },
        { address => "Route 66 Diner, 126 St. Robert Blvd, St. Robert, MO 65584" },
        { address => "Route 66 Neon Sign Park, 133 Reed Pkwy, St. Robert, MO 65584" },
        { address => "Old Stagecoach Stop, 106 N Lynn St, Waynesville, MO 65583" },
        { address => "Route 66 Gasconade Bridge, Richland, MO 65556" },
        { address => "Munger Moss Motel, 1336 U.S. Rt 66, Lebanon, MO 65536" },
        { address => "Smokin' Jones BBQ / Wrink's Market, 135 Wrinkle Ave, Lebanon, MO 65536" },
        { address => "Taylor's Dairy Joy, 1205 U.S. Rte 66, Lebanon, MO 65536" },
        { address => "The Manor House Inn, 505 E Elm St, Lebanon, MO 65536" },
        { address => "Route 66 Museum, 915 S Jefferson Ave, Lebanon, MO 65536" },
        { address => "Boswell Park Camp Joy, 51 Drury Ln, Lebanon, MO 65536" },
        { address => "Redmon's Candy Factory, 330 Pine St, Phillipsburg, MO 65722" },
        { address => "Buc-ee's, 3284 N Mulroy Rd, Springfield, MO 65803" },
        { address => "Andy's Frozen Custard, 2119 N Glenstone Ave, Springfield, MO 65803" },
        { address => "Best Western Route 66 Rail Haven, 203 S Glenstone Ave, Springfield, MO 65802" },
        { address => "Steak 'n Shake, 1158 E St Louis St, Springfield, MO 65802" },
        { address => "Gillioz Theatre, 325 Park Central E, Springfield, MO 65806" },
        { address => "History Museum on the Square, 154 Park Central Square, Springfield, MO 65806" },
        { address => "1984 Arcade, 400 S Jefferson Ave, Springfield, MO 65806" },
        { address => "Rogue Barber Co. & D's Wax Factory, 639 W Walnut St, Springfield, MO 65806" },
        { address => "College Street Cafe, 1622 W College St, Springfield, MO 65806" },
        { address => "Route 66 Car Museum, 1634 W College St, Springfield, MO 65806" },
        { address => "Rockwood Motor Court, 2200 W College St, Springfield, MO 65806" },
        { address => "Red's Giant Hamburg, 2301 W Sunshine St, Springfield, MO 65807" },
        { address => "Route 66 KOA Holiday, 5775 W Farm Rd 140, Springfield, MO 65802" },
        { address => "R & S Floral Factory Warehouse, 9323 MO-266, Springfield, MO 65802" },
        { address => "Gary's Gay Parita Sinclair, 21118 Old 66, Ash Grove, MO 65604" },
        { address => "Spencer Station, 19720 Lawrence 2062, Miller, MO 65707" },
        { address => "Red Oak II, 12275 Kafir Rd, Carthage, MO 64836" },
        { address => "Boots Court Motel, 125 S Garrison Ave, Carthage, MO 64836" },
        { address => "Whee Hill, 699 Oak St, Carthage, MO 64836" },
        { address => "66 Drive In, 17231 Old 66 Blvd, Carthage, MO 64836" },
        { address => "SuperTam on 66, 221 W Main St, Carterville, MO 64835" },
        { address => "Route 66 Center, 112 W Broadway St, Webb City, MO 64870" },
        { address => "Granny Shaffer's Restaurant, 2728 N Rangeline Rd, Joplin, MO 64801" },
        { address => "Royale Cinema Lounge, 715 E Broadway St, Joplin, MO 64801" },
        { address => "Wilder's Steakhouse, 1216 S Main St, Joplin, MO 64801" },
        { address => "Cars on the Route Kan-O-Tex Service Station, 199 N Main St, Galena, KS 66739" },
        { address => "Gearhead Curios, 520 Main St, Galena, KS 66739" },
        { address => "Galena Mining & Historical Museum, 319 W 7th St, Galena, KS 66739" },
        { address => "Old Riverton Store, 7109 KS-66, Riverton, KS 66770" },
        { address => "Rainbow Bridge, SE Beasley Rd, Baxter Springs, KS 66713" },
        { address => "Baxter Springs Heritage Center & Museum, 740 East Ave, Baxter Springs, KS 66713" },
        { address => "Route 66 Visitors Center, 940 Military Ave, Baxter Springs, KS 66713" },
        { address => "Dallas' Dairyette, 103 N Main St, Quapaw, OK 74363" },
        { address => "Dairy King, 100 N Main St, Commerce, OK 74339" },
        { address => "Waylan's Ku-Ku, 915 N Main St, Miami, OK 74354" },
        { address => "Coleman Theater, 103 N Main St, Miami, OK 74354" },
        { address => "Route 66 Sidewalk Hwy, S 540 Rd, Miami, OK 74354" },
        { address => "Clanton's Cafe, 319 E Illinois Ave, Vinita, OK 74301" },
        { address => "Crosstar Flag and Tag Museum, 103 S Central Ave, Afton, OK 74331" },
        { address => "Center Theater, 124 S Wilson St, Vinita, OK 74301" },
        { address => "Vinita Antique Mall on Route 66 & Jefferson Highway, 127 S Wilson St, Vinita, OK 74301" },
        { address => "Hi-Way Cafe and Western Motel, 437918 US-60, Vinita, OK 74301" },
        { address => "Underground Pedestrian Mural, 600 Walnut St, Chelsea, OK 74016" },
        { address => "Ed Galloway's Totem Pole Park, 21300 OK-28A, Chelsea, OK 74016" },
        { address => "Annie's Diner, 12015 Poplar St, Claremore, OK 74017" },
        { address => "J.M. Davis Arms & Historical Museum, 330 N JM Davis Blvd, Claremore, OK 74017" },
        { address => "Blue Whale of Catoosa, 2600 OK-66, Catoosa, OK 74015" },
        { address => "Tally's Good Food Cafe, 1102 S Yale Ave, Tulsa, OK 74112" },
        { address => "Golden Driller Statue, 4145 E 21st St, Tulsa, OK 74114" },
        { address => "The Campbell Hotel, 2636 E 11th St, Tulsa, OK 74104" },
        { address => "Circle Cinema, 10 S Lewis Ave, Tulsa, OK 74104" },
        { address => "The Outsiders House Museum, 731 N St Louis Ave, Tulsa, OK 74106" },
        { address => "Ike's Chili, 1503 E 11th St, Tulsa, OK 74120" },
        { address => "Buck Atom's Cosmic Curios on 66, 1347 E 11th St, Tulsa, OK 74120" },
        { address => "Buck's Vintage, 1317 E 11th St, Tulsa, OK 74120" },
        { address => "Meadow Gold Mack, 1306 E 11th St, Tulsa, OK 74120" },
        { address => "Swirl 66, 1802 S Cincinnati Ave, Tulsa, OK 74119" },
        { address => "Cyrus Avery Centennial Plaza, Southwest Blvd, Tulsa, OK 74127" },
        { address => "Route 66 Neon Sign Park, 1450 Southwest Blvd, Tulsa, OK 74107" },
        { address => "Route 66 Historical Village, 3770 Southwest Blvd, Tulsa, OK 74107" },
        { address => "Ollie's Station, 4070 Southwest Blvd, Tulsa, OK 74107" },
        { address => "The Roller Dome, 9661 New Sapulpa Rd, Sapulpa, OK 74066" },
        { address => "Dak's Market, 309 N Mission St, Sapulpa, OK 74066" },
        { address => "Happy Burger, 215 N Mission St, Sapulpa, OK 74066" },
        { address => "Gasoline Alley Classics, 24 N Main St, Sapulpa, OK 74066" },
        { address => "Heart of Route 66 Auto Museum, 13 Sahoma Lake Rd, Sapulpa, OK 74066" },
        { address => "Rock Creek Bridge, W Ozark Trail, Sapulpa, OK 74066" },
        { address => "J's Country Kitchen, 31 Oak St, Kellyville, OK 74136" },
        { address => "Bristow Route 66 Toy Museum, 118 N Main St, Bristow, OK 74010" },
        { address => "Bristow Train Depot and Museum, 1 Railroad Pl, Bristow, OK 74010" },
        { address => "Rock Cafe, 114 W Main St, Stroud, OK 74079" },
        { address => "Route 66 Spirit of America Museum, 220 W Main St, Stroud, OK 74079" },
        { address => "Skyliner Motel, 717 W Main St, Stroud, OK 74079" },
        { address => "Route 66 Bowl, 920 E 1st St, Chandler, OK 74834" },
        { address => "Route 66 Interpretive Center, 400 E 1st St, Chandler, OK 74834" },
        { address => "McJerry's Route 66 Gallery, 306 Manvel Ave, Chandler, OK 74834" },
        { address => "Westfall Phillips 66 Station, 701 Manvel Ave, Chandler, OK 74834" },
        { address => "Seaba Station Motorcycle Museum, 336992 E OK-66, Warwick, OK 74881" },
        { address => "John's Place Museum, 13441 OK-66, Arcadia, OK 73007" },
        { address => "Chicken Shack, 212 OK-66, Arcadia, OK 73007" },
        { address => "Arcadia Round Barn, 107 OK-66, Arcadia, OK 73007" },
        { address => "Pops 66, 660 OK-66, Arcadia, OK 73007" },
        { address => "1889 Territorial School, 124 E 2nd St, Edmond, OK 73034" },
        { address => "Bricktown Entertainment District, 111 S Mickey Mantle Dr, Oklahoma City, OK 73104" },
        { address => "Classen Inn, 820 N Classen Blvd, Oklahoma City, OK 73106" },
        { address => "Tower Theatre, 425 NW 23rd St, Oklahoma City, OK 73103" },
        { address => "Gold Dome Bank Building, 1112 NW 23rd St, Oklahoma City, OK 73106" },
        { address => "Milk Bottle Grocery, 2426 N Classen Blvd, Oklahoma City, OK 73106" },
        { address => "Lake Overholser Bridge, 8703–8709 Overholser Dr, Bethany, OK 73008" },
        { address => "Lakeview Market, 9025 N Overholser Dr, Yukon, OK 73099" },
        { address => "Yukon Mill & Grain Co., Yukon, OK 73099" },
        { address => "Sid's Diner, 300 S Choctaw Ave, El Reno, OK 73036" },
        { address => "The Filling Station, 120 S Choctaw Ave, El Reno, OK 73036" },
        { address => "Jobe's Country Boy Drive-In, 1220 Sunset Dr, El Reno, OK 73036" },
        { address => "Flat Giants Display, 10000 E 1020 Rd, Calumet, OK 73014" },
        { address => "Indian Trading Post, 825 S Walbaum Rd, Calumet, OK 73014" },
        { address => "Bridgeport Bridge, US-281, Hinton, OK 73047" },
        { address => "Gloria's Restaurant, 104 E Main St, Hydro, OK 73048" },
        { address => "Lucille's Historic Highway Gas Station, U.S. Route 66, Hydro, OK 73048" },
        { address => "Jerry's Diner, 1000 E Main St, Weatherford, OK 73096" },
        { address => "Centennial Park, N Broadway St, Weatherford, OK 73096" },
        { address => "The Glancy Motel, 217 W Gary Blvd, Clinton, OK 73601" },
        { address => "Oklahoma Route 66 Museum, 2229 W Gary Blvd, Clinton, OK 73601" },
        { address => "Foss, Foss, OK 73647" },
        { address => "Canute, Canute, OK 73626" },
        { address => "Flamingo Inn, 2000 W 3rd St, Elk City, OK 73644" },
        { address => "National Route 66 & Transportation Museum, 2717 W 3rd St, Elk City, OK 73644" },
        { address => "Sandhill Curiosity Shop, 201 S Sheb Wooley Ave, Erick, OK 73645" },
        { address => "Sam's Town on 66, 401 W Roger Miller Blvd, Erick, OK 73645" },
        { address => "West Winds Motel, 617 W Roger Miller Blvd, Erick, OK 73645" },
        { address => "U-Drop Inn Cafe, 105 E 12th St Shamrock TX, 79079" },
        { address => "Devil's Rope Barbed Wire Museum, 100 Kingsley St, McLean, TX 79057" },
        { address => "Restored 1929 Route 66 Gas Station, 212 First St, McLean, TX 79057 and 66 Super Service Station, 3rd Ave, Alanreed, TX 79057" },
        { address => "Leaning Tower of Texas, Groom, TX 79039" },
        { address => "Buc-ee's, 9900 E I-40, Amarillo, TX 79118" },
        { address => "The Big Texan Steak Ranch & Brewery, 7701 I-40, Amarillo, TX 79118" },
        { address => "Slug Bug Ranch, 1415 Sunrise Dr, Amarillo, TX 79104" },
        { address => "Texas Route 66 Visitor Center, 1900 SW 6th Ave, Amarillo, TX 79106" },
        { address => "Elmo's Drive Inn, 2618 SW 3rd Ave, Amarillo, TX 79106" },
        { address => "Lile Art Gallery, 2719 SW 6th Ave, Amarillo, TX 79106" },
        { address => "Smokey Joe's, 2903 SW 6th Ave, Amarillo, TX 79106" },
        { address => "GoldenLight Cafe & Cantina, 2906 SW 6th Ave, Amarillo, TX 79106" },
        { address => "Texas Ivy Antiques, 3511 SW 6th Ave, Amarillo, TX 79106" },
        { address => "The Handle Bar and Grill, 3514 SW 6th Ave, Amarillo, TX 79106" },
        { address => "Meme's Cafe, 3700 SW 6th Ave, Amarillo, TX" },
        { address => "2nd Amendment Cowboy Muffler Man, 2601 Hope Rd, Amarillo, TX" },
        { address => "Cadillac Ranch, 13651 I-40 Frontage Rd, Amarillo, TX 79124" },
        { address => "Milburn-Price Culture Museum, 1005 Coke St, Vega, TX 79092" },
        { address => "Mama Jo's Pies & Sweets, 922 E Main St, Vega, TX 79092" },
        { address => "Midpoint Cafe and Gift Shop, 305 Historic Rte 66, Adrian, TX 79001" },
        { address => "Dream Maker Station Route 66 Souvenir & Gift Shop, 307 U.S. Rte 66, Adrian, TX 79001" },
        { address => "Glenrio TX Ghost Town, I-40BL, Hereford, TX 79045" },
        { address => "Russell's Truck & Travel Center, 1583 Frontage Rd 4132, Glenrio, NM 88434" },
        { address => "World's Largest Flip Flop, 602 Route 66, San Jon, NM 88434" },
        { address => "Palomino Motel, 1215 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "Watson's BBQ, 502 S Lake St, Tucumcari, NM 88401" },
        { address => "Del's Restaurant, 1202 U.S. Rte 66, Tucumcari, NM 88401" },
        { address => "Tristar Inn Xpress, 1302 W Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "Roadrunner Lodge Motel, 1023 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "Golden Dragon Chinese Restaurant, 1006 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "TeePee Curios, 924 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "Blue Swallow Motel, 815 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "Motel Safari, 722 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { address => "Tucumcari Historical Museum, 416 S Adams St, Tucumcari, NM 88401" },
        { address => "Mesalands Dinosaur Museum & Natural Sciences Laboratory, 222 E Laughlin Ave, Tucumcari, NM 88401" },
        { address => "La Cita, 820 S 1st St, Tucumcari, NM 88401" },
        { address => "Blake's Lotaburger, 2523 S 1st St, Tucumcari, NM 88401" },
        { address => "Tucumcari Automotive, 401 W Tucumcari Blvd, Tucumcari, NM 88401, USA" },
        { address => "Ranch House Cafe, 1017 W Tucumcari Blvd, Tucumcari, NM 88401" },
        { address => "Route 66 Monument, 1500 U.S. Rte 66, Tucumcari, NM 88401" },
        { address => "Historic Newkirk post office, gas station & store, Emerald Rd, Cuervo, NM 88417" },
        { address => "Cuervo Ghost Town, Cuervo, NM 88417" },
        { address => "Route 66 Auto Museum, 2463 Historic Rte 66, Santa Rosa, NM 88435" },
        { address => "Old Rio Pecos Ranch Truck Terminal, 2358 U.S. Rte 66, Santa Rosa, NM 88435" },
        { address => "Sun & Sand Restaurant, 2050 U.S. Rte 66, Santa Rosa, NM 88435" },
        { address => "Pecos Theatre, 219 S 4th St, Santa Rosa, NM 88435" },
        { address => "Bowlin's Flying C Ranch, Exit 234, I-40, Encino, NM 88321" },
        { address => "Clines Corners Travel Center, Clines Corners, NM 87056" },
        { address => "Sal & Inez's Service Station, 421 U.S. Rte 66, Moriarty, NM 87035" },
        { address => "Country Friends Antiques, 1005 Old U.S. Rte 66, Moriarty, NM 87035" },
        { address => "Tinkertown Museum, 121 Sandia Crest Rd, Sandia Park, NM 87047" },
        { address => "Bow & Arrow Lodge, 8300 Central Ave SE, Albuquerque, NM 87108" },
        { address => "Loma Verde Motel, 7503 Central Ave NE, Albuquerque, NM 87108" },
        { address => "May Cafe, 111 Louisiana Blvd SE, Albuquerque, NM 87108" },
        { address => "Hurricane's Cafe, 4330 Lomas Blvd NE, Albuquerque, NM 87110" },
        { address => "Hotel Zazz, 3711 Central Ave NE, Albuquerque, NM 87108" },
        { address => "M'tucci's Bar Roma, 3222 Central Ave SE, Albuquerque, NM 87106" },
        { address => "Frontier Restaurant, 2400 Central Ave SE, Albuquerque, NM 87106" },
        { address => "66 Diner, 1405 Central Ave NE, Albuquerque, NM 87106" },
        { address => "The Imperial, 701 Central Ave NE, Albuquerque, NM 87102" },
        { address => "Kimo Theatre, 423 Central Ave NW, Albuquerque, NM 87102" },
        { address => "Lindy's Diner, 500 Central Ave SW, Albuquerque, NM 87102" },
        { address => "Dog House Drive In, 1216 Central Ave NW, Albuquerque, NM 87102" },
        { address => "El Vado Motel, 2500 Central Ave SW, Albuquerque, NM 87104" },
        { address => "Golden Pride, 5231 Central Ave NW, Albuquerque, NM 87105" },
        { address => "Western View Steak Diner & House, 6411 Central Ave NW, Albuquerque, NM 87105" },
        { address => "Westward Ho Motel, 4C25+X7, 7500 Central Ave SW, Albuquerque, NM 87121" },
        { address => "Cafe 66 New Mexican Restaurant, 9200 Central Ave SW, Albuquerque, NM 87121" },
        { address => "Enchanted Trails RV Park & Trading Post, 14305 Central Ave NW, Albuquerque, NM 87121" },
        { address => "Rio Puerco Bridge, 14311 Central Ave NW, Albuquerque, NM 87121" },
        { address => "Old Route 66 Road, 2702–2780 Old Rte 66 Rd, New Laguna, NM 87038" },
        { address => "Budville Trading Post, HC 77 Box 1A, Seama, NM 87007" },
        { address => "Villa de Cubero Trading Post, 1406 NM 124, Casa Blanca, NM 87007" },
        { address => "Ruins of Whiting Brothers Gas Station, San Fidel, NM 87049" },
        { address => "New Mexico Mining Museum, 100 Iron Ave, Grants, NM 87020" },
        { address => "Old Bluewater Motel, 2331 NM-122, Bluewater, NM 87005" },
        { address => "Bowlin's Bluewater Outpost, 136 Main St, Bluewater, NM 87005" },
        { address => "Thoreau, Thoreau, NM 87323" },
        { address => "Phillips 66, 101 U.S. Rte 66, Continental Divide, NM 87312" },
        { address => "Fort Wingate Army Depot, 506 U.S. Rte 66, Church Rock, NM 87311" },
        { address => "Earl's Family Restaurant, 1400 E Hwy 66, Gallup, NM 87301" },
        { address => "Historic El Rancho Hotel, 1000 E Hwy 66, Gallup, NM 87301" },
        { address => "John's Used Cars, 416 W Coal Ave, Gallup, NM 87301" },
        { address => "Yellowhorse Trading Post, I-40 Exit 359, Lupton, AZ 86508" },
        { address => "Fort Courage & Pancake House, Houck, AZ 86506" },
        { address => "Querino Canyon Bridge, Querino Dirt Rd, Houck, AZ 86506" },
        { address => "Dotch Windsor's Painted Desert Trading Post, Chambers, AZ 86502" },
        { address => "Petrified Forest National Park, Petrified Forest, AZ 86028" },
        { address => "Stewart's Petrified Wood Shop, Washboard Rd, Holbrook, AZ 86025" },
        { address => "Knife City Outlet, 7699 Sun Valley Rd, Sun Valley, AZ 86029" },
        { address => "El Rancho Restaurant & Motel, 867 Navajo Blvd, Holbrook, AZ 86025" },
        { address => "Old Landfill Site, 34.89166, -110.14122" },
        { address => "Wigwam Motel, 811 W Hopi Dr, Holbrook, AZ 86025" },
        { address => "Geronimo Trading Post, 5372 Geronimo Rd, Joseph City, AZ 86032" },
        { address => "Here It Is Jack Rabbit Trading Post, 3386 U.S. Rte 66, Joseph City, AZ 86032" },
        { address => "Falcon Restaurant & Lounge, 1113 E 3rd St, Winslow, AZ 86047" },
        { address => "Earl's Route 66 Motor Court, 512 E 3rd St, Winslow, AZ 86047" },
        { address => "La Posada Hotel, 303 E 2nd St, Winslow, AZ 86047" },
        { address => "Route 66 Delta Motel, 2141 W 3rd St, Winslow, AZ 86047" },
        { address => "Meteor City Trading Post, 40440 Interstate 40 WB, Winslow, AZ 86047" },
        { address => "Meteor Crater Natural Landmark, Meteor Crater Rd, AZ 86047" },
        { address => "Two Guns, AZ" },
        { address => "Twin Arrows Trading Post Ruins, East of Flagstaff, AZ 86004" },
        { address => "Canyon Padre Bridge, 35.16233, -111.28736" },
        { address => "Walnut Canyon Bridge, Townsend-Winona Rd, Winona, AZ" },
        { address => "Americana Motor Hotel, 2650 E Rte 66, Flagstaff, AZ 86004" },
        { address => "Route 66 Dog Haus, 1302 E Rte 66, Flagstaff, AZ 86001" },
        { address => "Flagstaff Visitor Center, 1 E Rte 66, Flagstaff, AZ 86001" },
        { address => "J. Lawrence Walkup Skydome, 1705 S San Francisco St, Flagstaff, AZ 86001" },
        { address => "Galaxy Diner, 931 W Rte 66, Flagstaff, AZ 86001" },
        { address => "Old Route 66 Parks Store, 12963 Old Rte 66 Ste 50340, Parks, AZ 86018" },
        { address => "Bearizona Wildlife Park, 1500 E Rte 66, Williams, AZ 86046" },
        { address => "Rod's Steak House, 301 E Historic Rte 66, Williams, AZ 86046" },
        { address => "Pete's Route 66 Gas Station Museum, 101 E Rte 66, Williams, AZ 86046" },
        { address => "Historic Grand Canyon Hotel, 145 Historic Rte 66, Williams, AZ 86046" },
        { address => "Williams Visitor Center, 200 W Railroad Ave, Williams, AZ 86046" },
        { address => "Cruiser's Route 66 Cafe, 233 W Rte 66, Williams, AZ 86046" },
        { address => "Arizona 9 Motor Hotel, 315 W Rte 66, Williams, AZ 86046" },
        { address => "Hi-Line Motel Sign, 127 Lewis Ave, Ash Fork, AZ 86320" },
        { address => "Ash Fork Route 66 Museum, 901 Old Rte 66, Ash Fork, AZ 86320" },
        { address => "Aztec Motel & Creative Space, 22200 Historic Rte 66, Seligman, AZ 86337" },
        { address => "Delgadillo's Snow Cap, 301 AZ-66, Seligman, AZ 86337" },
        { address => "Route 66 Road Relics, 22255 W Old Highway 66, Seligman, AZ 86337" },
        { address => "Rusty Bolt, 22345 W Old Highway 66, Seligman, AZ 86337" },
        { address => "Supai Motel, 22450 AZ-66, Seligman, AZ 86337" },
        { address => "Roadkill Cafe, 22830 W AZ-66, Seligman, AZ 86337" },
        { address => "Grand Canyon Caverns, AZ-66, Peach Springs, AZ 86434" },
        { address => "Frontier Motel Cafe, 16118 Historic Rte 66, Valentine, AZ 86437" },
        { address => "Old 76 Station, 12526 Historic Rte 66, Valentine, AZ 86437" },
        { address => "Hackberry General Store, 11255 AZ-66, Kingman, AZ 86411" },
        { address => "Arcadia Lodge, 909 E Andy Devine Ave, Kingman, AZ 86401" },
        { address => "TNT Auto Center, 535 E Andy Devine Ave, Kingman, AZ 86401" },
        { address => "Kingman Railroad Museum, 402 E Andy Devine Ave, Kingman, AZ 86401" },
        { address => "Sirens Cafe & Custom Catering, 419 Beale St, Kingman, AZ 86401" },
        { address => "Hotel Beale, 331 E Andy Devine Ave, Kingman, AZ 86401" },
        { address => "Tin Can Alley, 211 E Andy Devine Ave, Kingman, AZ 86401" },
        { address => "Mr. D'z Route 66 Diner, 105 E Andy Devine Ave, Kingman, AZ 86401" },
        { address => "Cool Springs Station, 8275 Oatman Rd, Golden Valley, AZ 86413" },
        { address => "Oatman, Oatman, AZ 86433" },
        { address => "Scenic Overlook, 34.97246, -114.41793" },
        { address => "Claypool & Co, 719 W Broadway St, Needles, CA 92363" },
        { address => "Needles Regional Museum, 929 Front St, Needles, CA 92363" },
        { address => "Wagon Wheel Restaurant, 2420 Needles Hwy, Needles, CA 92363" },
        { address => "Goffs Schoolhouse, 37198 Lanfair Rd, Essex, CA 92332" },
        { address => "Historic Road Runner's Retreat, Chambless, CA 92304" },
        { address => "Guardian Lion East, National Trails Hwy, Amboy, CA 92304" },
        { address => "Guardian Lion West, National Trails Hwy, Amboy, CA 92304" },
        { address => "Roy's Motel & Cafe, 87520 National Trails Hwy, Amboy, CA 92304" },
        { address => "Former Whiting Brothers Gas Station, 68517 County Rd 66, Ludlow, CA 92338" },
        { address => "Ludlow Cafe, 68315 National Trails Hwy, Ludlow, CA 92338" },
        { address => "Whiting Brothers Service / Tony's Spaghetti Building, 46756 National Trails Hwy, Newberry Springs, CA 92365" },
        { address => "Bagdad Cafe, 46548 National Trails Hwy, Newberry Springs, CA 92365" },
        { address => "Sand-Swallowed Abandoned Homes, Newberry Rd & Palma Vista Rd, Newberry Springs, CA 92365" },
        { address => "The Barn, 44560 National Trails Hwy, Newberry Springs, CA 92365" },
        { address => "The Russian House, 35421 County Rd 66, Daggett, CA 92327" },
        { address => "Desert Market, 35596 Santa Fe St, Daggett, CA 92327" },
        { address => "Daggett Garage, 35565 Santa Fe St, Daggett, CA 92327" },
        { address => "Daggett Historical Museum, 33703 2nd St, Daggett, CA 92327" },
        { address => "Penny's Diner, 35450 Yermo Rd, Yermo, CA 92398" },
        { address => "Peggy Sue's 50's Diner, 35654 Yermo Rd, Yermo, CA 92398" },
        { address => "Liberty Sculpture Park, 37570 Yermo Rd, Yermo, CA 92398" },
        { address => "EddieWorld, 36017 Calico Rd, Yermo, CA 92398" },
        { address => "Thrift & More, 457 W Yermo Rd, Yermo, CA 92398" },
        { address => "Original Del Taco Location, 38434 E Yermo Rd, Yermo, CA 92398" },
        { address => "Calico Ghost Town, Calico, CA 92311" },
        { address => "Skyline Drive-In Theater, 31175 Old Hwy 58, Barstow, CA" },
        { address => "Pit Stop Bar & Grill, 560 Victor St, Barstow, CA 92311" },
        { address => "Barstow Train McDonald's, 1611 E Main St, Barstow, CA 92311" },
        { address => "Mojave River Valley Museum, 270 E Virginia Way, Barstow, CA 92311" },
        { address => "Harvey House, 685 N 1st Ave, Barstow, CA 92311" },
        { address => "20 Mule Team Museum, 26962 Twenty Mule Team Rd, Boron, CA 93516" },
        { address => "Elmer's Bottle Tree Ranch, 24266 National Trails Hwy, Oro Grande, CA 92368" },
        { address => "Emma Jean's Holland Burger Cafe, 17143 N D St, Victorville, CA 92394" },
        { address => "California Route 66 Museum, 16825 D St, Victorville, CA 92395" },
        { address => "Santa Fe Trading Company, 15464 7th St, Victorville, CA 92395" },
        { address => "First Original McDonald's Museum, 1398 N E St, San Bernardino, CA 92405" },
        { address => "Mitla Cafe, 602 N Mt Vernon Ave, San Bernardino, CA 92411" },
        { address => "Wigwam Village Motel, 2728 Foothill Blvd, San Bernardino, CA 92410" },
        { address => "Cucamonga Service Station, 9670 Foothill Blvd, Rancho Cucamonga, CA 91730" },
        { address => "The Sycamore Inn, 8318 Foothill Blvd, Rancho Cucamonga, CA 91730" },
        { address => "Magic Lamp Inn Restaurant, 8189 Foothill Blvd, Rancho Cucamonga, CA 91730" },
        { address => "The Donut Man, 915 E Route 66, Glendora, CA 91741" },
        { address => "690 E Foothill Blvd, Azusa, CA 91702" },
        { address => "Windmill Denny's, 7 E Huntington Dr, Arcadia, CA 91006" },
        { address => "Saga Motor Hotel, 1633 E Colorado Blvd, Pasadena, CA 91106" },
        { address => "Shakers, 601 Fair Oaks Ave, South Pasadena, CA 91030" },
        { address => "Fair Oaks Pharmacy & Soda Fountain, 1526 Mission St, South Pasadena, CA 91030" },
        { address => "Rialto Theatre, 1023 Fair Oaks Ave, South Pasadena, CA 91030" },
        { address => "Galco's Old World Grocery, 5702 York Blvd, Los Angeles, CA 90042" },
        { address => "Highland Park Bowl, 5621 N Figueroa St, Los Angeles, CA 90042" },
        { address => "La Fuente Restaurant, 5552 N Figueroa St, Los Angeles, CA 90042" },
        { address => "Cielito Lindo, E-23 Olvera St, Los Angeles, CA 90012" },
        { address => "Million Dollar Theater, 307 S Broadway, Los Angeles, CA 90013" },
        { address => "Clifton's, 648 S Broadway, Los Angeles, CA 90014" },
        { address => "The Orpheum Theatre, 842 S Broadway, Los Angeles, CA 90014" },
        { address => "The United Theater on Broadway, 929 S Broadway, Los Angeles, CA 90015" },
        { address => "Petersen Automotive Museum, 6060 Wilshire Blvd, Los Angeles, CA 90036" },
        { address => "Tesla Diner, 7001 Santa Monica Blvd, Los Angeles, CA 90038" },
        { address => "The Formosa, 7156 Santa Monica Blvd, West Hollywood, CA 90046" },
        { address => "Irv's Burgers, 7998 Santa Monica Blvd, West Hollywood, CA 90046" },
        { address => "Barney's Beanery, 8447 Santa Monica Blvd, West Hollywood, CA 90069" },
        { address => "Tail O' the Pup, 8512 Santa Monica Blvd, West Hollywood, CA 90069" },
        { address => "NORMS Restaurant, 470 N La Cienega Blvd, West Hollywood, CA 90048" },
        { address => "Edelweiss Chocolates, 444 N Canon Dr, Beverly Hills, CA 90210" },
        { address => "Cafe 50's, 11623 Santa Monica Blvd, Los Angeles, CA 90025" },
        { address => "Mel's Drive-In, 1670 Lincoln Blvd, Santa Monica, CA 90404" },
        { address => "Cal Mar Hotel Suites, 220 California Ave, Santa Monica, CA 90403" },
        { address => "Santa Monica Pier, 200 Santa Monica Pier, Santa Monica, CA 90401" },
    ];

    my $work_dir = './data';
    my $qr_dir   = './data/qr_codes/';
    my $out_docx = './data/wasteland_firebirds_big_list-base.docx';
    my $qr_width = '4.0in';

    set_up_qr_dir($qr_dir);
    ensure_dir($work_dir);
    my $qrs = generate_qr_codes( $addresses, $qr_dir );
    make_doc( $addresses, $qrs, $work_dir, $qr_dir, $qr_width, $out_docx );

    print "Open DOCX in Pages.\nClick Document, Section, uncheck Left and Right are Different.\nClick Document, Document, Footer. Then go to the footer and click it and Insert Page Number. Do any other needed tweaks then export PDF.\n";
    system( 'open', $out_docx );
}

sub ensure_dir {
    my ($d) = @_;
    -d $d or mkdir $d or die "Can't mkdir $d: $!";
}

sub md_escape {
    my ($s) = @_;
    $s //= '';
    $s =~ s/\R/ /g;
    $s =~ s/^\s+|\s+$//g;
    $s =~ s/([\\`*_{}\[\]()#+\-.!|>])/\\$1/g;
    return $s;
}

sub set_up_qr_dir {
    my ($output_dir) = @_;
    unless ( -d $output_dir ) {
        make_path($output_dir)
          or die "Failed to create directory $output_dir: $!";
    }

    # clean out old QR codes if present
    mkdir $output_dir;
    opendir( my $dh, $output_dir ) or die "Can't open $output_dir: $!";
    while ( my $file = readdir($dh) ) {
        next if $file eq '.' or $file eq '..';
        my $path = "$output_dir/$file";
        next if -d $path;    # skip subdirectories
        unlink($path) or warn "Couldn't delete $path: $!";
    }
    closedir($dh);
}

sub generate_qr_codes {
    my ( $addresses, $output_dir ) = @_;
    my $count = 0;
    my $qrs;
    for my $address_hashref (@$addresses) {
        my $address = $address_hashref->{address};
        chomp $address;
        $count++;

        # Create the Google Maps URL
        my $query    = uri_escape_utf8($address);
        my $maps_url = "https://www.google.com/maps/search/?api=1&query=$query";

        # Generate the QR Code, Ecc => 1 is Error Correction Level L (Low), ModuleSize controls the pixel size of the blocks
        my $qrobj = GD::Barcode::QRcode->new( $maps_url, { Ecc => 1, ModuleSize => 4 } );
        print "$maps_url\n";
        if ($qrobj) {

            # Create a safe filename
            my $safe_name = $address;
            $safe_name =~ s/[^a-zA-Z0-9_\- ]//g;
            $safe_name =~ s/ /_/g;

            # Limit length to avoid filesystem errors
            $safe_name = substr( $safe_name, 0, 30 );
            my $filename = sprintf( "%03d_%s.png", $count, $safe_name );
            my $filepath = "$output_dir/$filename";
            open my $img_fh, '>', $filepath or die "Could not open '$filepath' for writing: $!";
            binmode $img_fh;

            # Adding some padding to left or right side, alternating
            my $qr = $qrobj->plot();
            my ( $w, $h ) = $qr->getBounds();
            my $pad = 0;
            if ( $count % 2 == 1 ) {
                $pad = $w;
            }
            my $canvas = GD::Image->new( $w + $w, $h );
            my $white  = $canvas->colorAllocate( 255, 255, 255 );
            my $black  = $canvas->colorAllocate( 0,   0,   0 );
            $canvas->filledRectangle( 0, 0, $w + $pad, $h, $white );
            $canvas->copy( $qr, $pad, 0, 0, 0, $w, $h );
            $canvas->rectangle( 0, 0, $w + $w - 1, $h - 1, $black );
            print $img_fh $canvas->png();
            close $img_fh;
            push( @$qrs, $filename );
        }
        else {
            die "[$count] Error generating QR code for: $address\n";
        }
    }
    return $qrs;
}

sub make_doc {
    my ( $addresses, $qrs, $work_dir, $qr_dir, $qr_width, $out_docx ) = @_;

    # Build a Pandoc-flavored Markdown file with page breaks
    my $md_path = File::Spec->catfile( $work_dir, 'book.md' );
    open my $md, '>', $md_path or die "Can't write $md_path: $!";

    # .md breaks that can be understood by pandoc and translated into word breaks
    my $line_break = "  \n";
    my $page_break = "```{=openxml}\n<w:p><w:r><w:br w:type=\"page\"/></w:r></w:p>\n```\n\n";

    # Title page
    print $md "Wasteland Firebird's Big List${line_break}of the Best Things On Route 66${line_break}by Wasteland Firebird (John Binns)${line_break}Second Edition Summer 2026 Centennial${line_break}";
    print $md $page_break;

    # Copyright page
    print $md "Copyright © 2026 John Binns${line_break}All rights reserved${line_break}wastelandfirebird\@gmail.com${line_break}youtube.com/wastelandfirebird${line_break}wastelandfirebird.com${line_break}";
    print $md $page_break;

    # Dedication
    print $md "In 1987, Angel Delgadillo saved Route 66.${line_break}In 2006, Pixar's Cars saved Route 66.${line_break}2026 is the Centennial of Route 66.${line_break}Who will save it now, if not you and me?${line_break}";
    print $md $page_break;

    # Introduction
    print $md qq|
Prepare to be inspired
${line_break}
On July 4, 1976, I wasn't even four years old. But, that year, I learned a big word. Bicentennial. Everyone was saying it so much. How could I not have learned it? "Bicentennial." It was spoken with such obvious reverence that my young ears paid attention.
${line_break}
Fifty years later, I am the one speaking reverence to young ears. Are you paying attention?
${line_break}
Say it with me. "Semiquincentennial." Do any three-year-olds know that word? How many adults know it? Semiquincentennial.
${line_break}
Semi means half, quin means five, cent means hundred, ennial means years. The United States of America has now existed for half of 500 years.
${line_break}
I was hoping for another Freedom Train, a Wagon Train Pilgrimage, NYC's Operation Sail, TV shows, special coins, special edition cars, fireworks, air shows, car shows, parades, and red-white-and-blue everything. A few of those things are happening, but something has definitely changed in the last fifty years. The reverence is gone.
${line_break}
When I discovered that Route 66 would have its Centennial in the same year as America's Semiquincentennial, I went to work. I had to do something to bring that reverence back.
${line_break}
I traveled Route 66 four times. I made a bunch of YouTube videos about it. I took a lot of notes. I drew up flyers for a free event I was calling The Great Route 66 Centennial Convergence. I made t-shirts and keychains based on hand-drawn art. I commissioned miniature "Muffler Man" action figures of myself. I promoted this event so much that I was kicked off of Facebook forever for being a "spammer."
${line_break}
Most importantly, I created the First Edition of this book. Like the t-shirts, keychains, and action figures, the First Edition was never for sale. It was free for Convergence participants. There are still a few copies floating around out there.
${line_break}
The Great Route 66 Centennial Convergence came to an end on April 30, 2026. But people kept asking for copies of the book. So here it is. The Second Edition. You can buy it at wastelandfirebird.com. You might still manage to find a free copy, if you look hard enough. I always tell people to check the Route 66 of Chenoa IL Roadside Attraction Tourist Info booth. You never know what you might find in that thing.
${line_break}
Will there ever be another Convergence? I'll put it this way. I'll be traveling Route 66 as much as I can for the rest of my life. I'd be delighted if you, your friends, and your family, found me, followed me, and asked me questions, all along the way. But pay attention to my answers. And pay attention to my reverence.
${line_break}
Route 66 has always represented the American Dream. If we save Route 66, we save the American Dream. If we save the American Dream, we save America. If we save America, we save the world. Because the American Dream is not just America's dream. It's everyone's dream.
${line_break}
|;
    print $md $page_break;

    # How to use this book
    print $md qq|
How to use this book
${line_break}
This book is a list of QR codes that represent online directions to each of my favorite places on Route 66. You can scan these QR codes with your phone by pointing the phone's camera at them. If you scan every QR code, and visit every place in this book, you will approximately follow Route 66. There is no app that you need to download.
${line_break}
If you want to follow Route 66 more exactly, you'll need to do more research. But be aware that there never was a single "Route 66." There have always been many "alignments" (alternate routes). And nowadays, much of what used to be known as "Route 66" consists of potholed roads, dirt roads, private roads, government roads, and dead ends. If you want to explore all of it, you'd better give yourself at least a year.
${line_break}
Some of the passport-style books you'll find on the Route require small businesses to pay thousands of dollars for the privilege of being advertised in those books. I'm not saying that's a bad thing. I'm just saying it's something you should know. Many businesses along the Route have custom rubber "passport stamps." I've left an empty space beside all of the QR codes for those stamps, if you want to use them to mark your progress. You could also use those spaces for notes, signatures, stickers, or just big checkmarks.
${line_break}
No one paid to be in this book. This book is nothing more than a list of places and people that I love.
${line_break}
|;
    print $md $page_break;
    my $qr_num = 0;
    for my $address_hashref (@$addresses) {
        my $address = $address_hashref->{address};
        my $qr_path = File::Spec->catfile( $qr_dir, $qrs->[$qr_num] );
        if ( !-f $qr_path ) {
            die "Missing QR file for '$qr_num': " . Dumper($qrs);
        }

        # Address (as plain paragraph). If you want it to be, say, a big bold title},
        # define a style in reference.docx and switch to it later via a pandoc Lua filter.
        print $md md_escape($address), "\n\n";

        # Pandoc supports attribute syntax: {width=...}
        print $md "![]($qr_path){width=$qr_width}\n\n";

        # Page break
        print $md $page_break;
        $qr_num++;
    }
    close $md or die "Error closing $md_path: $!";

    # Your print-on-demand formatting is controlled by this DOCX.
    # Make a DOCX that matches the POD template (margins, page size, headers/footers, fonts, etc).
    # Pandoc calls this a "reference docx".
    my $reference_docx = './data/wasteland_firebirds_big_list-template.docx';

    #    Convert Markdown -> DOCX using reference.docx for layout
    #    This is the key: reference_docx defines page size/margins/fonts like your POD template.
    my @cmd = ( 'pandoc', $md_path, '-o', $out_docx, '--reference-doc=' . $reference_docx, );
    print "Running:\n  " . join( ' ', map { /\s/ ? qq("$_") : $_ } @cmd ) . "\n";
    system(@cmd) == 0 or die "pandoc failed (exit " . ( $? >> 8 ) . ")\n";
}
main();

