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
        { name => "Art Institute of Chicago",                                address => "111 S Michigan Ave, Chicago, IL 60603" },
        { name => "Cloud Gate",                                              address => "201 E Randolph St, Chicago, IL 60602" },
        { name => "Historic Illinois US 66 Route Signage",                   address => "E Adams St & S Michigan Ave, Chicago, IL" },
        { name => "Lou Mitchell's",                                          address => "565 W Jackson Blvd, Chicago, IL 60661" },
        { name => "Lulu's Hot Dogs",                                         address => "1000 S Leavitt St, Chicago, IL 60612" },
        { name => "Steak 'n Egger",                                          address => "5647 Ogden Ave, Cicero, IL 60804" },
        { name => "Henry's Drive-In",                                        address => "6031 Ogden Ave, Cicero, IL 60804" },
        { name => "Cigars & Stripes BBQ Lounge",                             address => "6715 Ogden Ave, Berwyn, IL 60402" },
        { name => "Dell Rhea's Chicken Basket",                              address => "645 Joliet Rd, Willowbrook, IL 60527" },
        { name => "White Fence Farm Restaurant",                             address => "1376 Joliet Rd, Romeoville, IL 60446" },
        { name => "The Beller Museum",                                       address => "275 Rocbaar Dr, Romeoville, IL 60446" },
        { name => "Old Joliet Prison",                                       address => "1125 Collins St, Joliet, IL 60432" },
        { name => "Joliet Area Historical Museum",                           address => "204 N Ottawa St, Joliet, IL 60432" },
        { name => "Rialto Square Theatre",                                   address => "102 N Chicago St, Joliet, IL 60432" },
        { name => "Blues Brothers Copmobile",                                address => "2410 S Chicago St, Joliet, IL 60436" },
        { name => "Art on 66",                                               address => "208 N Water St, Wilmington, IL 60481" },
        { name => "Gemini Giant",                                            address => "201 Bridge St, Wilmington, IL 60481" },
        { name => "Polk-A-Dot Drive In",                                     address => "222 N Front St, Braidwood, IL 60408" },
        { name => "The Shop on Route 66",                                    address => "315 N Center St, Gardner, IL 60424" },
        { name => "80s Car Museum",                                          address => "316 W Waupansie St, Dwight, IL 60420" },
        { name => "Gothic Church Dwight Townhall",                           address => "201 N Franklin St, Dwight, IL 60420" },
        { name => "Dwight Coin Laundry",                                     address => "404 W Waupansie St, Dwight, IL 60420" },
        { name => "Ambler's Texaco Gas Station",                             address => "W Waupansie St, Dwight, IL 60420" },
        { name => "Standard Oil Gas Station",                                address => "400 S West St, Odell, IL 60460" },
        { name => "Route 66 Association of Illinois",                        address => "110 W Howard St, Pontiac, IL 61764" },
        { name => "Pontiac Oakland Auto Museum",                             address => "205 N Mill St, Pontiac, IL 61764" },
        { name => "Wally's",                                                 address => "1 Holiday Rd, Pontiac, IL 61764" },
        { name => "Route 66 of Chenoa Roadside Attraction & Tourist Info",   address => "P7RC+C3, Chenoa IL 61726" },
        { name => "Lexington Route 66 Memory Lane",                          address => "Parade Rd, Lexington, IL 61753" },
        { name => "The Shake Shack",                                         address => "512 W Main St, Lexington, IL 61753" },
        { name => "Sprague's Super Service Station",                         address => "305 Pine St, Normal, IL 61761" },
        { name => "Carl's Ice Cream Factory",                                address => "1700 W College Ave, Normal, IL 61761" },
        { name => "Funks Grove Pure Maple Sirup Farm",                       address => "Funks Grove Township, IL 61754" },
        { name => "Pinball Paradise",                                        address => "102 E Morgan St, McLean, IL 61754" },
        { name => "Arcadia: America's Playable Arcade Museum",               address => "107 S Hamilton St, McLean, IL 61754" },
        { name => "Country-Aire Restaurant",                                 address => "606 E South St, Atlanta, IL 61723" },
        { name => "American Giants Museum",                                  address => "100 SW St, Atlanta, IL 61723" },
        { name => "Hot Dog Muffler Man",                                     address => "112 SW Arch St, Atlanta, IL 61723" },
        { name => "The Mill Museum on Route 66",                             address => "738 S Washington St, Lincoln, IL 62656" },
        { name => "Wild Hare Cafe",                                          address => "104 Governor Oglesby St, Elkhart, IL 62634" },
        { name => "The Old Station",                                         address => "117 Elm St, Williamsville, IL 62693" },
        { name => "Outkast Tattoo Studio",                                   address => "2828 N Peoria Rd, Springfield, IL 62702" },
        { name => "Illinois State Fair Route 66 Experience",                 address => "801 E Sangamon Ave, Springfield, IL 62702" },
        { name => "Route 66 Hotel & Conference Center",                      address => "625 E St Joseph St, Springfield, IL 62703" },
        { name => "Shea's Filling Station",                                  address => "2075 N Peoria Rd, Springfield, IL 62702" },
        { name => "Maid-Rite",                                               address => "118 N Pasfield St, Springfield, IL 62702" },
        { name => "Pharmacy Gallery & Art Space",                            address => "623 E Adams St, Springfield, IL 62701" },
        { name => "Springfield Southeast High School",                       address => "2350 E Ash St, Springfield, IL 62703" },
        { name => "Mel-O-Cream Donuts",                                      address => "217 E Laurel St, Springfield, IL 62704" },
        { name => "Ace Sign Co.",                                            address => "2540 S 1st St, Springfield, IL 62704" },
        { name => "Charlie Parker's Diner",                                  address => "700 W North St, Springfield, IL 62704" },
        { name => "Lauterbach Muffler Man",                                  address => "1569 Wabash Ave, Springfield, IL 62704" },
        { name => "Pinky Elephant with Martini",                             address => "2723 S 6th St, Springfield, IL 62703" },
        { name => "Cozy Dog",                                                address => "2935 S 6th St, Springfield, IL 62703" },
        { name => "Curve Inn",                                               address => "3219 S 6th St, Springfield, IL 62703" },
        { name => "Route 66 Motorheads Bar and Grill",                       address => "600 Toronto Rd, Springfield, IL 62711" },
        { name => "Sangamo Brewing",                                         address => "109 E Mulberry St, Chatham, IL 62629" },
        { name => "Chatham Railroad Museum",                                 address => "100 N State St, Chatham, IL 62629" },
        { name => "Illinois Brick Road",                                     address => "4995–4790 Snell Rd, Auburn, IL 62615" },
        { name => "Sly Fox Bookstore",                                       address => "123 N Springfield St, Virden, IL 62690" },
        { name => "Doc's Just Off 66",                                       address => "133 S 2nd St, Girard, IL 62640" },
        { name => "Whirl A Whip",                                            address => "309 S 3rd St, Girard, IL 62640" },
        { name => "Turkey Tracks on Route 66",                               address => "26618–27306 Donaldson Rd, Girard, IL 62640" },
        { name => "Carlinvilla Motel",                                       address => "18891 State Rte 4, Carlinville, IL 62626" },
        { name => "Rt 66 Skyview Drive-In",                                  address => "1500 Old Rte 66 N, Litchfield, IL 62056" },
        { name => "Niehaus Cycle Sales",                                     address => "718 Old Rte 66 N, Litchfield, IL 62056" },
        { name => "The Ariston Cafe",                                        address => "413 Old Rte 66 N, Litchfield, IL 62056" },
        { name => "Litchfield Museum & Route 66 Welcome Center",             address => "334 Old Rte 66 N, Litchfield, IL 62056" },
        { name => "Soulsby Service Station",                                 address => "710 W 1st St, Mt Olive, IL 62069" },
        { name => "Henry's Rabbit Ranch",                                    address => "1107 Historic Old Rte 66, Staunton, IL 62088" },
        { name => "DeCamp Station",                                          address => "8767 State Rte 4, Staunton, IL 62088" },
        { name => "Pink Elephant Antique Mall",                              address => "908 Veterans Memorial Dr, Livingston, IL 62058" },
        { name => "Route 66 Creamery",                                       address => "11 S Old Rte 66, Hamel, IL 62046" },
        { name => "Weezy's",                                                 address => "108 Old Rte 66, Hamel, IL 62046" },
        { name => "Wildey Theatre",                                          address => "252 N Main St, Edwardsville, IL 62025" },
        { name => "West End Service Station",                                address => "620 St Louis St, Edwardsville, IL 62025" },
        { name => "Luna Cafe",                                               address => "201 E Chain of Rocks Rd, Granite City, IL 62040" },
        { name => "Old Chain of Rocks Bridge",                               address => "10820 Riverview Dr, St. Louis, MO 63137" },
        { name => "O'Brien Tire & Auto Care",                                address => "3924 Nameoki Rd, Granite City, IL 62040" },
        { name => "Mr. Twist Ice Cream",                                     address => "2649 Madison Ave, Granite City, IL 62040" },
        { name => "It's Electric Neon Sign Park",                            address => "1300 19th St, Granite City, IL 62040" },
        { name => "614 Niedringhaus Ave",                                    address => "Granite City, IL 62040" },
        { name => "Crown Candy Kitchen",                                     address => "1401 St Louis Ave, St. Louis, MO 63106" },
        { name => "Skate King Roller Rink",                                  address => "2700 Kienlen Ave, St. Louis, MO 63121" },
        { name => "The Gateway Arch",                                        address => "St. Louis, MO 63102" },
        { name => "Neon Museum of St. Louis",                                address => "3537 Chouteau Ave, St. Louis, MO 63103" },
        { name => "Ted Drewes Frozen Custard",                               address => "6726 Chippewa St, St. Louis, MO 63109" },
        { name => "Wally's",                                                 address => "950 Assembly Pkwy, Fenton, MO 63026" },
        { name => "The Malt Shop",                                           address => "1751 Smizer Station Rd, Fenton, MO 63026" },
        { name => "Route 66 State Park",                                     address => "97 N Outer Rd, Eureka, MO 63025" },
        { name => "Campbell's Service",                                      address => "18625 Historic Rte 66, Pacific, MO 63069" },
        { name => "Red Cedar Inn Museum and Visitor Center",                 address => "1047 E Osage St, Pacific, MO 63069" },
        { name => "2827 MO-100",                                             address => "Villa Ridge, MO 63089" },
        { name => "Old Sunset Motel",                                        address => "976 Osage Villa Ct, Villa Ridge, MO 63089" },
        { name => "Creative Chainsaw Carvings",                              address => "151 State Rte W, Sullivan, MO 63080" },
        { name => "Meramec Caverns",                                         address => "1135 Hwy W, Sullivan, MO 63080" },
        { name => "Shamrock Court Motel",                                    address => "101 Shamrock, Sullivan, MO 63080" },
        { name => "Missouri Hick Barbeque",                                  address => "913 E Washington Blvd, Cuba, MO 65453" },
        { name => "Wagon Wheel Motel",                                       address => "901 E Washington Blvd, Cuba, MO 65453" },
        { name => "Weir on 66 / Rich's Famous Burgers",                      address => "102 W Washington St, Cuba, MO 65453" },
        { name => "Fanning Outpost Rocking Chair",                           address => "5957 State Hwy ZZ, Cuba, MO 65453" },
        { name => "Mule Trading Post",                                       address => "11160 Dillon Outer Rd, Rolla, MO 65401" },
        { name => "John's Modern Cabins on Route 66",                        address => "11107 Arlington Outer Rd, Newburg, MO 65550" },
        { name => "Arlington",                                               address => "Arlington, MO 65550" },
        { name => "Devil's Elbow Bridge",                                    address => "Big Piney River, Devils Elbow, MO 65457" },
        { name => "Uranus Fudge Factory",                                    address => "14400 State Hwy Z, St. Robert, MO 65584" },
        { name => "Route 66 Diner",                                          address => "126 St. Robert Blvd, St. Robert, MO 65584" },
        { name => "Route 66 Neon Sign Park",                                 address => "133 Reed Pkwy, St. Robert, MO 65584" },
        { name => "Old Stagecoach Stop",                                     address => "106 N Lynn St, Waynesville, MO 65583" },
        { name => "Route 66 Gasconade Bridge",                               address => "Richland, MO 65556" },
        { name => "Munger Moss Motel",                                       address => "1336 U.S. Rt 66, Lebanon, MO 65536" },
        { name => "Smokin' Jones BBQ / Wrink's Market",                      address => "135 Wrinkle Ave, Lebanon, MO 65536" },
        { name => "Taylor's Dairy Joy",                                      address => "1205 U.S. Rte 66, Lebanon, MO 65536" },
        { name => "The Manor House Inn",                                     address => "505 E Elm St, Lebanon, MO 65536" },
        { name => "Route 66 Museum",                                         address => "915 S Jefferson Ave, Lebanon, MO 65536" },
        { name => "Boswell Park Camp Joy",                                   address => "51 Drury Ln, Lebanon, MO 65536" },
        { name => "Redmon's Candy Factory",                                  address => "330 Pine St, Phillipsburg, MO 65722" },
        { name => "Buc-ee's",                                                address => "3284 N Mulroy Rd, Springfield, MO 65803" },
        { name => "Andy's Frozen Custard",                                   address => "2119 N Glenstone Ave, Springfield, MO 65803" },
        { name => "Best Western Route 66 Rail Haven",                        address => "203 S Glenstone Ave, Springfield, MO 65802" },
        { name => "Steak 'n Shake",                                          address => "1158 E St Louis St, Springfield, MO 65802" },
        { name => "Gillioz Theatre",                                         address => "325 Park Central E, Springfield, MO 65806" },
        { name => "History Museum on the Square",                            address => "154 Park Central Square, Springfield, MO 65806" },
        { name => "1984 Arcade",                                             address => "400 S Jefferson Ave, Springfield, MO 65806" },
        { name => "Rogue Barber Co. & D's Wax Factory",                      address => "639 W Walnut St, Springfield, MO 65806" },
        { name => "College Street Cafe",                                     address => "1622 W College St, Springfield, MO 65806" },
        { name => "Route 66 Car Museum",                                     address => "1634 W College St, Springfield, MO 65806" },
        { name => "Rockwood Motor Court",                                    address => "2200 W College St, Springfield, MO 65806" },
        { name => "Red's Giant Hamburg",                                     address => "2301 W Sunshine St, Springfield, MO 65807" },
        { name => "Route 66 KOA Holiday",                                    address => "5775 W Farm Rd 140, Springfield, MO 65802" },
        { name => "R & S Floral Factory Warehouse",                          address => "9323 MO-266, Springfield, MO 65802" },
        { name => "Gary's Gay Parita Sinclair",                              address => "21118 Old 66, Ash Grove, MO 65604" },
        { name => "Spencer Station",                                         address => "19720 Lawrence 2062, Miller, MO 65707" },
        { name => "Red Oak II",                                              address => "12275 Kafir Rd, Carthage, MO 64836" },
        { name => "Boots Court Motel",                                       address => "125 S Garrison Ave, Carthage, MO 64836" },
        { name => "Whee Hill",                                               address => "699 Oak St, Carthage, MO 64836" },
        { name => "66 Drive In",                                             address => "17231 Old 66 Blvd, Carthage, MO 64836" },
        { name => "SuperTam on 66",                                          address => "221 W Main St, Carterville, MO 64835" },
        { name => "Route 66 Center",                                         address => "112 W Broadway St, Webb City, MO 64870" },
        { name => "Granny Shaffer's Restaurant",                             address => "2728 N Rangeline Rd, Joplin, MO 64801" },
        { name => "Royale Cinema Lounge",                                    address => "715 E Broadway St, Joplin, MO 64801" },
        { name => "Wilder's Steakhouse",                                     address => "1216 S Main St, Joplin, MO 64801" },
        { name => "Cars on the Route Kan-O-Tex Service Station",             address => "199 N Main St, Galena, KS 66739" },
        { name => "Gearhead Curios",                                         address => "520 Main St, Galena, KS 66739" },
        { name => "Galena Mining & Historical Museum",                       address => "319 W 7th St, Galena, KS 66739" },
        { name => "Old Riverton Store",                                      address => "7109 KS-66, Riverton, KS 66770" },
        { name => "Rainbow Bridge",                                          address => "SE Beasley Rd, Baxter Springs, KS 66713" },
        { name => "Baxter Springs Heritage Center & Museum",                 address => "740 East Ave, Baxter Springs, KS 66713" },
        { name => "Route 66 Visitors Center",                                address => "940 Military Ave, Baxter Springs, KS 66713" },
        { name => "Dallas' Dairyette",                                       address => "103 N Main St, Quapaw, OK 74363" },
        { name => "Dairy King",                                              address => "100 N Main St, Commerce, OK 74339" },
        { name => "Waylan's Ku-Ku",                                          address => "915 N Main St, Miami, OK 74354" },
        { name => "Coleman Theater",                                         address => "103 N Main St, Miami, OK 74354" },
        { name => "Route 66 Sidewalk Hwy",                                   address => "S 540 Rd, Miami, OK 74354" },
        { name => "Clanton's Cafe",                                          address => "319 E Illinois Ave, Vinita, OK 74301" },
        { name => "Crosstar Flag and Tag Museum",                            address => "103 S Central Ave, Afton, OK 74331" },
        { name => "Center Theater",                                          address => "124 S Wilson St, Vinita, OK 74301" },
        { name => "Vinita Antique Mall on Route 66 & Jefferson Highway",     address => "127 S Wilson St, Vinita, OK 74301" },
        { name => "Hi-Way Cafe and Western Motel",                           address => "437918 US-60, Vinita, OK 74301" },
        { name => "Underground Pedestrian Mural",                            address => "600 Walnut St, Chelsea, OK 74016" },
        { name => "Ed Galloway's Totem Pole Park",                           address => "21300 OK-28A, Chelsea, OK 74016" },
        { name => "Annie's Diner",                                           address => "12015 Poplar St, Claremore, OK 74017" },
        { name => "J.M. Davis Arms & Historical Museum",                     address => "330 N JM Davis Blvd, Claremore, OK 74017" },
        { name => "Blue Whale of Catoosa",                                   address => "2600 OK-66, Catoosa, OK 74015" },
        { name => "Tally's Good Food Cafe",                                  address => "1102 S Yale Ave, Tulsa, OK 74112" },
        { name => "Golden Driller Statue",                                   address => "4145 E 21st St, Tulsa, OK 74114" },
        { name => "The Campbell Hotel",                                      address => "2636 E 11th St, Tulsa, OK 74104" },
        { name => "Circle Cinema",                                           address => "10 S Lewis Ave, Tulsa, OK 74104" },
        { name => "The Outsiders House Museum",                              address => "731 N St Louis Ave, Tulsa, OK 74106" },
        { name => "Ike's Chili",                                             address => "1503 E 11th St, Tulsa, OK 74120" },
        { name => "Buck Atom's Cosmic Curios on 66",                         address => "1347 E 11th St, Tulsa, OK 74120" },
        { name => "Buck's Vintage",                                          address => "1317 E 11th St, Tulsa, OK 74120" },
        { name => "Meadow Gold Mack",                                        address => "1306 E 11th St, Tulsa, OK 74120" },
        { name => "Swirl 66",                                                address => "1802 S Cincinnati Ave, Tulsa, OK 74119" },
        { name => "Cyrus Avery Centennial Plaza",                            address => "Southwest Blvd, Tulsa, OK 74127" },
        { name => "Route 66 Neon Sign Park",                                 address => "1450 Southwest Blvd, Tulsa, OK 74107" },
        { name => "Route 66 Historical Village",                             address => "3770 Southwest Blvd, Tulsa, OK 74107" },
        { name => "Ollie's Station",                                         address => "4070 Southwest Blvd, Tulsa, OK 74107" },
        { name => "The Roller Dome",                                         address => "9661 New Sapulpa Rd, Sapulpa, OK 74066" },
        { name => "Dak's Market",                                            address => "309 N Mission St, Sapulpa, OK 74066" },
        { name => "Happy Burger",                                            address => "215 N Mission St, Sapulpa, OK 74066" },
        { name => "Gasoline Alley Classics",                                 address => "24 N Main St, Sapulpa, OK 74066" },
        { name => "Heart of Route 66 Auto Museum",                           address => "13 Sahoma Lake Rd, Sapulpa, OK 74066" },
        { name => "Rock Creek Bridge",                                       address => "W Ozark Trail, Sapulpa, OK 74066" },
        { name => "J's Country Kitchen",                                     address => "31 Oak St, Kellyville, OK 74136" },
        { name => "Bristow Route 66 Toy Museum",                             address => "118 N Main St, Bristow, OK 74010" },
        { name => "Bristow Train Depot and Museum",                          address => "1 Railroad Pl, Bristow, OK 74010" },
        { name => "Rock Cafe",                                               address => "114 W Main St, Stroud, OK 74079" },
        { name => "Route 66 Spirit of America Museum",                       address => "220 W Main St, Stroud, OK 74079" },
        { name => "Skyliner Motel",                                          address => "717 W Main St, Stroud, OK 74079" },
        { name => "Route 66 Bowl",                                           address => "920 E 1st St, Chandler, OK 74834" },
        { name => "Route 66 Interpretive Center",                            address => "400 E 1st St, Chandler, OK 74834" },
        { name => "McJerry's Route 66 Gallery",                              address => "306 Manvel Ave, Chandler, OK 74834" },
        { name => "Westfall Phillips 66 Station",                            address => "701 Manvel Ave, Chandler, OK 74834" },
        { name => "Seaba Station Motorcycle Museum",                         address => "336992 E OK-66, Warwick, OK 74881" },
        { name => "John's Place Museum",                                     address => "13441 OK-66, Arcadia, OK 73007" },
        { name => "Chicken Shack",                                           address => "212 OK-66, Arcadia, OK 73007" },
        { name => "Arcadia Round Barn",                                      address => "107 OK-66, Arcadia, OK 73007" },
        { name => "Pops 66",                                                 address => "660 OK-66, Arcadia, OK 73007" },
        { name => "1889 Territorial School",                                 address => "124 E 2nd St, Edmond, OK 73034" },
        { name => "Bricktown Entertainment District",                        address => "111 S Mickey Mantle Dr, Oklahoma City, OK 73104" },
        { name => "Classen Inn",                                             address => "820 N Classen Blvd, Oklahoma City, OK 73106" },
        { name => "Tower Theatre",                                           address => "425 NW 23rd St, Oklahoma City, OK 73103" },
        { name => "Gold Dome Bank Building",                                 address => "1112 NW 23rd St, Oklahoma City, OK 73106" },
        { name => "Milk Bottle Grocery",                                     address => "2426 N Classen Blvd, Oklahoma City, OK 73106" },
        { name => "Lake Overholser Bridge",                                  address => "8703–8709 Overholser Dr, Bethany, OK 73008" },
        { name => "Lakeview Market",                                         address => "9025 N Overholser Dr, Yukon, OK 73099" },
        { name => "Yukon Mill & Grain Co.",                                  address => "Yukon, OK 73099" },
        { name => "Sid's Diner",                                             address => "300 S Choctaw Ave, El Reno, OK 73036" },
        { name => "The Filling Station",                                     address => "120 S Choctaw Ave, El Reno, OK 73036" },
        { name => "Jobe's Country Boy Drive-In",                             address => "1220 Sunset Dr, El Reno, OK 73036" },
        { name => "Flat Giants Display",                                     address => "10000 E 1020 Rd, Calumet, OK 73014" },
        { name => "Indian Trading Post",                                     address => "825 S Walbaum Rd, Calumet, OK 73014" },
        { name => "Bridgeport Bridge",                                       address => "US-281, Hinton, OK 73047" },
        { name => "Gloria's Restaurant",                                     address => "104 E Main St, Hydro, OK 73048" },
        { name => "Lucille's Historic Highway Gas Station",                  address => "U.S. Route 66, Hydro, OK 73048" },
        { name => "Jerry's Diner",                                           address => "1000 E Main St, Weatherford, OK 73096" },
        { name => "Centennial Park",                                         address => "N Broadway St, Weatherford, OK 73096" },
        { name => "The Glancy Motel",                                        address => "217 W Gary Blvd, Clinton, OK 73601" },
        { name => "Oklahoma Route 66 Museum",                                address => "2229 W Gary Blvd, Clinton, OK 73601" },
        { name => "Foss",                                                    address => "Foss, OK 73647" },
        { name => "Canute",                                                  address => "Canute, OK 73626" },
        { name => "Flamingo Inn",                                            address => "2000 W 3rd St, Elk City, OK 73644" },
        { name => "National Route 66 & Transportation Museum",               address => "2717 W 3rd St, Elk City, OK 73644" },
        { name => "Sandhill Curiosity Shop",                                 address => "201 S Sheb Wooley Ave, Erick, OK 73645" },
        { name => "Sam's Town on 66",                                        address => "401 W Roger Miller Blvd, Erick, OK 73645" },
        { name => "West Winds Motel",                                        address => "617 W Roger Miller Blvd, Erick, OK 73645" },
        { name => "U-Drop Inn Cafe",                                         address => "105 E 12th St Shamrock TX, 79079" },
        { name => "Devil's Rope Barbed Wire Museum",                         address => "100 Kingsley St, McLean, TX 79057" },
        { name => "Restored 1929 Route 66 Gas Station",                      address => "212 First St, McLean, TX 79057 and 66 Super Service Station, 3rd Ave, Alanreed, TX 79057" },
        { name => "Leaning Tower of Texas",                                  address => "Groom, TX 79039" },
        { name => "Buc-ee's",                                                address => "9900 E I-40, Amarillo, TX 79118" },
        { name => "The Big Texan Steak Ranch & Brewery",                     address => "7701 I-40, Amarillo, TX 79118" },
        { name => "Slug Bug Ranch",                                          address => "1415 Sunrise Dr, Amarillo, TX 79104" },
        { name => "Texas Route 66 Visitor Center",                           address => "1900 SW 6th Ave, Amarillo, TX 79106" },
        { name => "Elmo's Drive Inn",                                        address => "2618 SW 3rd Ave, Amarillo, TX 79106" },
        { name => "Lile Art Gallery",                                        address => "2719 SW 6th Ave, Amarillo, TX 79106" },
        { name => "Smokey Joe's",                                            address => "2903 SW 6th Ave, Amarillo, TX 79106" },
        { name => "GoldenLight Cafe & Cantina",                              address => "2906 SW 6th Ave, Amarillo, TX 79106" },
        { name => "Texas Ivy Antiques",                                      address => "3511 SW 6th Ave, Amarillo, TX 79106" },
        { name => "The Handle Bar and Grill",                                address => "3514 SW 6th Ave, Amarillo, TX 79106" },
        { name => "Meme's Cafe",                                             address => "3700 SW 6th Ave, Amarillo, TX" },
        { name => "2nd Amendment Cowboy Muffler Man",                        address => "2601 Hope Rd, Amarillo, TX" },
        { name => "Cadillac Ranch",                                          address => "13651 I-40 Frontage Rd, Amarillo, TX 79124" },
        { name => "Milburn-Price Culture Museum",                            address => "1005 Coke St, Vega, TX 79092" },
        { name => "Mama Jo's Pies & Sweets",                                 address => "922 E Main St, Vega, TX 79092" },
        { name => "Midpoint Cafe and Gift Shop",                             address => "305 Historic Rte 66, Adrian, TX 79001" },
        { name => "Dream Maker Station Route 66 Souvenir & Gift Shop",       address => "307 U.S. Rte 66, Adrian, TX 79001" },
        { name => "Glenrio TX Ghost Town",                                   address => "I-40BL, Hereford, TX 79045" },
        { name => "Russell's Truck & Travel Center",                         address => "1583 Frontage Rd 4132, Glenrio, NM 88434" },
        { name => "World's Largest Flip Flop",                               address => "602 Route 66, San Jon, NM 88434" },
        { name => "Palomino Motel",                                          address => "1215 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "Watson's BBQ",                                            address => "502 S Lake St, Tucumcari, NM 88401" },
        { name => "Del's Restaurant",                                        address => "1202 U.S. Rte 66, Tucumcari, NM 88401" },
        { name => "Tristar Inn Xpress",                                      address => "1302 W Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "Roadrunner Lodge Motel",                                  address => "1023 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "Golden Dragon Chinese Restaurant",                        address => "1006 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "TeePee Curios",                                           address => "924 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "Blue Swallow Motel",                                      address => "815 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "Motel Safari",                                            address => "722 E Rte 66 Blvd, Tucumcari, NM 88401" },
        { name => "Tucumcari Historical Museum",                             address => "416 S Adams St, Tucumcari, NM 88401" },
        { name => "Mesalands Dinosaur Museum & Natural Sciences Laboratory", address => "222 E Laughlin Ave, Tucumcari, NM 88401" },
        { name => "La Cita",                                                 address => "820 S 1st St, Tucumcari, NM 88401" },
        { name => "Blake's Lotaburger",                                      address => "2523 S 1st St, Tucumcari, NM 88401" },
        { name => "Tucumcari Automotive",                                    address => "401 W Tucumcari Blvd, Tucumcari, NM 88401, USA" },
        { name => "Ranch House Cafe",                                        address => "1017 W Tucumcari Blvd, Tucumcari, NM 88401" },
        { name => "Route 66 Monument",                                       address => "1500 U.S. Rte 66, Tucumcari, NM 88401" },
        { name => "Historic Newkirk post office",                            address => "gas station & store, Emerald Rd, Cuervo, NM 88417" },
        { name => "Cuervo Ghost Town",                                       address => "Cuervo, NM 88417" },
        { name => "Route 66 Auto Museum",                                    address => "2463 Historic Rte 66, Santa Rosa, NM 88435" },
        { name => "Old Rio Pecos Ranch Truck Terminal",                      address => "2358 U.S. Rte 66, Santa Rosa, NM 88435" },
        { name => "Sun & Sand Restaurant",                                   address => "2050 U.S. Rte 66, Santa Rosa, NM 88435" },
        { name => "Pecos Theatre",                                           address => "219 S 4th St, Santa Rosa, NM 88435" },
        { name => "Bowlin's Flying C Ranch",                                 address => "Exit 234, I-40, Encino, NM 88321" },
        { name => "Clines Corners Travel Center",                            address => "Clines Corners, NM 87056" },
        { name => "Sal & Inez's Service Station",                            address => "421 U.S. Rte 66, Moriarty, NM 87035" },
        { name => "Country Friends Antiques",                                address => "1005 Old U.S. Rte 66, Moriarty, NM 87035" },
        { name => "Tinkertown Museum",                                       address => "121 Sandia Crest Rd, Sandia Park, NM 87047" },
        { name => "Bow & Arrow Lodge",                                       address => "8300 Central Ave SE, Albuquerque, NM 87108" },
        { name => "Loma Verde Motel",                                        address => "7503 Central Ave NE, Albuquerque, NM 87108" },
        { name => "May Cafe",                                                address => "111 Louisiana Blvd SE, Albuquerque, NM 87108" },
        { name => "Hurricane's Cafe",                                        address => "4330 Lomas Blvd NE, Albuquerque, NM 87110" },
        { name => "Hotel Zazz",                                              address => "3711 Central Ave NE, Albuquerque, NM 87108" },
        { name => "M'tucci's Bar Roma",                                      address => "3222 Central Ave SE, Albuquerque, NM 87106" },
        { name => "Frontier Restaurant",                                     address => "2400 Central Ave SE, Albuquerque, NM 87106" },
        { name => "66 Diner",                                                address => "1405 Central Ave NE, Albuquerque, NM 87106" },
        { name => "The Imperial",                                            address => "701 Central Ave NE, Albuquerque, NM 87102" },
        { name => "Kimo Theatre",                                            address => "423 Central Ave NW, Albuquerque, NM 87102" },
        { name => "Lindy's Diner",                                           address => "500 Central Ave SW, Albuquerque, NM 87102" },
        { name => "Dog House Drive In",                                      address => "1216 Central Ave NW, Albuquerque, NM 87102" },
        { name => "El Vado Motel",                                           address => "2500 Central Ave SW, Albuquerque, NM 87104" },
        { name => "Golden Pride",                                            address => "5231 Central Ave NW, Albuquerque, NM 87105" },
        { name => "Western View Steak Diner & House",                        address => "6411 Central Ave NW, Albuquerque, NM 87105" },
        { name => "Westward Ho Motel",                                       address => "4C25+X7, 7500 Central Ave SW, Albuquerque, NM 87121" },
        { name => "Cafe 66 New Mexican Restaurant",                          address => "9200 Central Ave SW, Albuquerque, NM 87121" },
        { name => "Enchanted Trails RV Park & Trading Post",                 address => "14305 Central Ave NW, Albuquerque, NM 87121" },
        { name => "Rio Puerco Bridge",                                       address => "14311 Central Ave NW, Albuquerque, NM 87121" },
        { name => "Old Route 66 Road",                                       address => "2702–2780 Old Rte 66 Rd, New Laguna, NM 87038" },
        { name => "Budville Trading Post",                                   address => "HC 77 Box 1A, Seama, NM 87007" },
        { name => "Villa de Cubero Trading Post",                            address => "1406 NM 124, Casa Blanca, NM 87007" },
        { name => "Ruins of Whiting Brothers Gas Station",                   address => "San Fidel, NM 87049" },
        { name => "New Mexico Mining Museum",                                address => "100 Iron Ave, Grants, NM 87020" },
        { name => "Old Bluewater Motel",                                     address => "2331 NM-122, Bluewater, NM 87005" },
        { name => "Bowlin's Bluewater Outpost",                              address => "136 Main St, Bluewater, NM 87005" },
        { name => "Thoreau",                                                 address => "Thoreau, NM 87323" },
        { name => "Phillips 66",                                             address => "101 U.S. Rte 66, Continental Divide, NM 87312" },
        { name => "Fort Wingate Army Depot",                                 address => "506 U.S. Rte 66, Church Rock, NM 87311" },
        { name => "Earl's Family Restaurant",                                address => "1400 E Hwy 66, Gallup, NM 87301" },
        { name => "Historic El Rancho Hotel",                                address => "1000 E Hwy 66, Gallup, NM 87301" },
        { name => "John's Used Cars",                                        address => "416 W Coal Ave, Gallup, NM 87301" },
        { name => "Yellowhorse Trading Post",                                address => "I-40 Exit 359, Lupton, AZ 86508" },
        { name => "Fort Courage & Pancake House",                            address => "Houck, AZ 86506" },
        { name => "Querino Canyon Bridge",                                   address => "Querino Dirt Rd, Houck, AZ 86506" },
        { name => "Dotch Windsor's Painted Desert Trading Post",             address => "Chambers, AZ 86502" },
        { name => "Petrified Forest National Park",                          address => "Petrified Forest, AZ 86028" },
        { name => "Stewart's Petrified Wood Shop",                           address => "Washboard Rd, Holbrook, AZ 86025" },
        { name => "Knife City Outlet",                                       address => "7699 Sun Valley Rd, Sun Valley, AZ 86029" },
        { name => "El Rancho Restaurant & Motel",                            address => "867 Navajo Blvd, Holbrook, AZ 86025" },
        { name => "Old Landfill Site",                                       address => "34.89166, -110.14122" },
        { name => "Wigwam Motel",                                            address => "811 W Hopi Dr, Holbrook, AZ 86025" },
        { name => "Geronimo Trading Post",                                   address => "5372 Geronimo Rd, Joseph City, AZ 86032" },
        { name => "Here It Is Jack Rabbit Trading Post",                     address => "3386 U.S. Rte 66, Joseph City, AZ 86032" },
        { name => "Falcon Restaurant & Lounge",                              address => "1113 E 3rd St, Winslow, AZ 86047" },
        { name => "Earl's Route 66 Motor Court",                             address => "512 E 3rd St, Winslow, AZ 86047" },
        { name => "La Posada Hotel",                                         address => "303 E 2nd St, Winslow, AZ 86047" },
        { name => "Route 66 Delta Motel",                                    address => "2141 W 3rd St, Winslow, AZ 86047" },
        { name => "Meteor City Trading Post",                                address => "40440 Interstate 40 WB, Winslow, AZ 86047" },
        { name => "Meteor Crater Natural Landmark",                          address => "Meteor Crater Rd, AZ 86047" },
        { name => "Two Guns",                                                address => "AZ" },
        { name => "Twin Arrows Trading Post Ruins",                          address => "East of Flagstaff, AZ 86004" },
        { name => "Canyon Padre Bridge",                                     address => "35.16233, -111.28736" },
        { name => "Walnut Canyon Bridge",                                    address => "Townsend-Winona Rd, Winona, AZ" },
        { name => "Americana Motor Hotel",                                   address => "2650 E Rte 66, Flagstaff, AZ 86004" },
        { name => "Route 66 Dog Haus",                                       address => "1302 E Rte 66, Flagstaff, AZ 86001" },
        { name => "Flagstaff Visitor Center",                                address => "1 E Rte 66, Flagstaff, AZ 86001" },
        { name => "J. Lawrence Walkup Skydome",                              address => "1705 S San Francisco St, Flagstaff, AZ 86001" },
        { name => "Galaxy Diner",                                            address => "931 W Rte 66, Flagstaff, AZ 86001" },
        { name => "Old Route 66 Parks Store",                                address => "12963 Old Rte 66 Ste 50340, Parks, AZ 86018" },
        { name => "Bearizona Wildlife Park",                                 address => "1500 E Rte 66, Williams, AZ 86046" },
        { name => "Rod's Steak House",                                       address => "301 E Historic Rte 66, Williams, AZ 86046" },
        { name => "Pete's Route 66 Gas Station Museum",                      address => "101 E Rte 66, Williams, AZ 86046" },
        { name => "Historic Grand Canyon Hotel",                             address => "145 Historic Rte 66, Williams, AZ 86046" },
        { name => "Williams Visitor Center",                                 address => "200 W Railroad Ave, Williams, AZ 86046" },
        { name => "Cruiser's Route 66 Cafe",                                 address => "233 W Rte 66, Williams, AZ 86046" },
        { name => "Arizona 9 Motor Hotel",                                   address => "315 W Rte 66, Williams, AZ 86046" },
        { name => "Hi-Line Motel Sign",                                      address => "127 Lewis Ave, Ash Fork, AZ 86320" },
        { name => "Ash Fork Route 66 Museum",                                address => "901 Old Rte 66, Ash Fork, AZ 86320" },
        { name => "Aztec Motel & Creative Space",                            address => "22200 Historic Rte 66, Seligman, AZ 86337" },
        { name => "Delgadillo's Snow Cap",                                   address => "301 AZ-66, Seligman, AZ 86337" },
        { name => "Route 66 Road Relics",                                    address => "22255 W Old Highway 66, Seligman, AZ 86337" },
        { name => "Rusty Bolt",                                              address => "22345 W Old Highway 66, Seligman, AZ 86337" },
        { name => "Supai Motel",                                             address => "22450 AZ-66, Seligman, AZ 86337" },
        { name => "Roadkill Cafe",                                           address => "22830 W AZ-66, Seligman, AZ 86337" },
        { name => "Grand Canyon Caverns",                                    address => "AZ-66, Peach Springs, AZ 86434" },
        { name => "Frontier Motel Cafe",                                     address => "16118 Historic Rte 66, Valentine, AZ 86437" },
        { name => "Old 76 Station",                                          address => "12526 Historic Rte 66, Valentine, AZ 86437" },
        { name => "Hackberry General Store",                                 address => "11255 AZ-66, Kingman, AZ 86411" },
        { name => "Arcadia Lodge",                                           address => "909 E Andy Devine Ave, Kingman, AZ 86401" },
        { name => "TNT Auto Center",                                         address => "535 E Andy Devine Ave, Kingman, AZ 86401" },
        { name => "Kingman Railroad Museum",                                 address => "402 E Andy Devine Ave, Kingman, AZ 86401" },
        { name => "Sirens Cafe & Custom Catering",                           address => "419 Beale St, Kingman, AZ 86401" },
        { name => "Hotel Beale",                                             address => "331 E Andy Devine Ave, Kingman, AZ 86401" },
        { name => "Tin Can Alley",                                           address => "211 E Andy Devine Ave, Kingman, AZ 86401" },
        { name => "Mr. D'z Route 66 Diner",                                  address => "105 E Andy Devine Ave, Kingman, AZ 86401" },
        { name => "Cool Springs Station",                                    address => "8275 Oatman Rd, Golden Valley, AZ 86413" },
        { name => "Oatman",                                                  address => "Oatman, AZ 86433" },
        { name => "Scenic Overlook",                                         address => "34.97246, -114.41793" },
        { name => "Claypool & Co",                                           address => "719 W Broadway St, Needles, CA 92363" },
        { name => "Needles Regional Museum",                                 address => "929 Front St, Needles, CA 92363" },
        { name => "Wagon Wheel Restaurant",                                  address => "2420 Needles Hwy, Needles, CA 92363" },
        { name => "Goffs Schoolhouse",                                       address => "37198 Lanfair Rd, Essex, CA 92332" },
        { name => "Historic Road Runner's Retreat",                          address => "Chambless, CA 92304" },
        { name => "Guardian Lion East",                                      address => "National Trails Hwy, Amboy, CA 92304" },
        { name => "Guardian Lion West",                                      address => "National Trails Hwy, Amboy, CA 92304" },
        { name => "Roy's Motel & Cafe",                                      address => "87520 National Trails Hwy, Amboy, CA 92304" },
        { name => "Former Whiting Brothers Gas Station",                     address => "68517 County Rd 66, Ludlow, CA 92338" },
        { name => "Ludlow Cafe",                                             address => "68315 National Trails Hwy, Ludlow, CA 92338" },
        { name => "Whiting Brothers Service / Tony's Spaghetti Building",    address => "46756 National Trails Hwy, Newberry Springs, CA 92365" },
        { name => "Bagdad Cafe",                                             address => "46548 National Trails Hwy, Newberry Springs, CA 92365" },
        { name => "Sand-Swallowed Abandoned Homes",                          address => "Newberry Rd & Palma Vista Rd, Newberry Springs, CA 92365" },
        { name => "The Barn",                                                address => "44560 National Trails Hwy, Newberry Springs, CA 92365" },
        { name => "The Russian House",                                       address => "35421 County Rd 66, Daggett, CA 92327" },
        { name => "Desert Market",                                           address => "35596 Santa Fe St, Daggett, CA 92327" },
        { name => "Daggett Garage",                                          address => "35565 Santa Fe St, Daggett, CA 92327" },
        { name => "Daggett Historical Museum",                               address => "33703 2nd St, Daggett, CA 92327" },
        { name => "Penny's Diner",                                           address => "35450 Yermo Rd, Yermo, CA 92398" },
        { name => "Peggy Sue's 50's Diner",                                  address => "35654 Yermo Rd, Yermo, CA 92398" },
        { name => "Liberty Sculpture Park",                                  address => "37570 Yermo Rd, Yermo, CA 92398" },
        { name => "EddieWorld",                                              address => "36017 Calico Rd, Yermo, CA 92398" },
        { name => "Thrift & More",                                           address => "457 W Yermo Rd, Yermo, CA 92398" },
        { name => "Original Del Taco Location",                              address => "38434 E Yermo Rd, Yermo, CA 92398" },
        { name => "Calico Ghost Town",                                       address => "Calico, CA 92311" },
        { name => "Skyline Drive-In Theater",                                address => "31175 Old Hwy 58, Barstow, CA" },
        { name => "Pit Stop Bar & Grill",                                    address => "560 Victor St, Barstow, CA 92311" },
        { name => "Barstow Train McDonald's",                                address => "1611 E Main St, Barstow, CA 92311" },
        { name => "Mojave River Valley Museum",                              address => "270 E Virginia Way, Barstow, CA 92311" },
        { name => "Harvey House",                                            address => "685 N 1st Ave, Barstow, CA 92311" },
        { name => "20 Mule Team Museum",                                     address => "26962 Twenty Mule Team Rd, Boron, CA 93516" },
        { name => "Elmer's Bottle Tree Ranch",                               address => "24266 National Trails Hwy, Oro Grande, CA 92368" },
        { name => "Emma Jean's Holland Burger Cafe",                         address => "17143 N D St, Victorville, CA 92394" },
        { name => "California Route 66 Museum",                              address => "16825 D St, Victorville, CA 92395" },
        { name => "Santa Fe Trading Company",                                address => "15464 7th St, Victorville, CA 92395" },
        { name => "First Original McDonald's Museum",                        address => "1398 N E St, San Bernardino, CA 92405" },
        { name => "Mitla Cafe",                                              address => "602 N Mt Vernon Ave, San Bernardino, CA 92411" },
        { name => "Wigwam Village Motel",                                    address => "2728 Foothill Blvd, San Bernardino, CA 92410" },
        { name => "Cucamonga Service Station",                               address => "9670 Foothill Blvd, Rancho Cucamonga, CA 91730" },
        { name => "The Sycamore Inn",                                        address => "8318 Foothill Blvd, Rancho Cucamonga, CA 91730" },
        { name => "Magic Lamp Inn Restaurant",                               address => "8189 Foothill Blvd, Rancho Cucamonga, CA 91730" },
        { name => "The Donut Man",                                           address => "915 E Route 66, Glendora, CA 91741" },
        { name => "690 E Foothill Blvd",                                     address => "Azusa, CA 91702" },
        { name => "Windmill Denny's",                                        address => "7 E Huntington Dr, Arcadia, CA 91006" },
        { name => "Saga Motor Hotel",                                        address => "1633 E Colorado Blvd, Pasadena, CA 91106" },
        { name => "Shakers",                                                 address => "601 Fair Oaks Ave, South Pasadena, CA 91030" },
        { name => "Fair Oaks Pharmacy & Soda Fountain",                      address => "1526 Mission St, South Pasadena, CA 91030" },
        { name => "Rialto Theatre",                                          address => "1023 Fair Oaks Ave, South Pasadena, CA 91030" },
        { name => "Galco's Old World Grocery",                               address => "5702 York Blvd, Los Angeles, CA 90042" },
        { name => "Highland Park Bowl",                                      address => "5621 N Figueroa St, Los Angeles, CA 90042" },
        { name => "La Fuente Restaurant",                                    address => "5552 N Figueroa St, Los Angeles, CA 90042" },
        { name => "Cielito Lindo",                                           address => "E-23 Olvera St, Los Angeles, CA 90012" },
        { name => "Million Dollar Theater",                                  address => "307 S Broadway, Los Angeles, CA 90013" },
        { name => "Clifton's",                                               address => "648 S Broadway, Los Angeles, CA 90014" },
        { name => "The Orpheum Theatre",                                     address => "842 S Broadway, Los Angeles, CA 90014" },
        { name => "The United Theater on Broadway",                          address => "929 S Broadway, Los Angeles, CA 90015" },
        { name => "Petersen Automotive Museum",                              address => "6060 Wilshire Blvd, Los Angeles, CA 90036" },
        { name => "Tesla Diner",                                             address => "7001 Santa Monica Blvd, Los Angeles, CA 90038" },
        { name => "The Formosa",                                             address => "7156 Santa Monica Blvd, West Hollywood, CA 90046" },
        { name => "Irv's Burgers",                                           address => "7998 Santa Monica Blvd, West Hollywood, CA 90046" },
        { name => "Barney's Beanery",                                        address => "8447 Santa Monica Blvd, West Hollywood, CA 90069" },
        { name => "Tail O' the Pup",                                         address => "8512 Santa Monica Blvd, West Hollywood, CA 90069" },
        { name => "NORMS Restaurant",                                        address => "470 N La Cienega Blvd, West Hollywood, CA 90048" },
        { name => "Edelweiss Chocolates",                                    address => "444 N Canon Dr, Beverly Hills, CA 90210" },
        { name => "Cafe 50's",                                               address => "11623 Santa Monica Blvd, Los Angeles, CA 90025" },
        { name => "Mel's Drive-In",                                          address => "1670 Lincoln Blvd, Santa Monica, CA 90404" },
        { name => "Cal Mar Hotel Suites",                                    address => "220 California Ave, Santa Monica, CA 90403" },
        { name => "Santa Monica Pier",                                       address => "200 Santa Monica Pier, Santa Monica, CA 90401" },
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
        my $place_name = $address_hashref->{name};
        my $address    = $address_hashref->{address};
        chomp $address;
        if ( $address !~ /^[0-9]/ ) {
            $address = "$place_name, $address";
        }
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

    # Build a Pandoc md file
    my $md_path = File::Spec->catfile( $work_dir, 'book.md' );
    open my $md, '>', $md_path or die "Can't write $md_path: $!";

    # md breaks that can be understood by pandoc and translated into docx breaks
    my $line_break = "  \n";
    my $page_break = "```{=openxml}\n<w:p><w:r><w:br w:type=\"page\"/></w:r></w:p>\n```\n\n";

    # Title page
    print $md "Wasteland Firebird's Big List${line_break}of the Best Things On Route 66${line_break}by Wasteland Firebird (John Binns)${line_break}Second Edition Summer 2026 Centennial${line_break}";
    print $md $page_break;

    # Copyright page
    print $md "Copyright © 2026 John Binns${line_break}All rights reserved${line_break}wastelandfirebird\@gmail.com${line_break}youtube.com/wastelandfirebird${line_break}wastelandfirebird.com${line_break}";
    print $md $page_break;

    # Dedication page
    print $md "In 1987, Angel Delgadillo saved Route 66.${line_break}In 2006, Pixar's Cars saved Route 66.${line_break}2026 is the Centennial of Route 66.${line_break}Who will save it now, if not you and me?${line_break}";
    print $md $page_break;

    # Introduction pages
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
        my $place_name = $address_hashref->{name};
        my $address    = $address_hashref->{address};
        my $qr_path    = File::Spec->catfile( $qr_dir, $qrs->[$qr_num] );
        if ( !-f $qr_path ) {
            die "Missing QR file for '$qr_num': " . Dumper($qrs);
        }

        # Address (as plain paragraph). If you want it to be, say, a big bold title},
        # define a style in reference.docx and switch to it later via a pandoc Lua filter.
        print $md md_escape($place_name), "\n\n";
        print $md $line_break;
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

