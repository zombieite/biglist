#!/usr/bin/env perl
use strict;
use warnings;
use GD qw(gdTinyFont);
use GD::Barcode::QRcode;
use URI::Escape qw(uri_escape_utf8);
use File::Path  qw(make_path);
use File::Basename;
use Cwd qw(abs_path);
use Data::Dumper;

sub main {

    # md breaks that can be understood by pandoc and translated into docx breaks
    my $line_break = "  \n";
    my $page_break = "```{=openxml}\n<w:p><w:r><w:br w:type=\"page\"/></w:r></w:p>\n```\n\n";
    my $addresses  = [
        {
            name    => "Navy Pier",
            address => "600 E Grand Ave, Chicago IL",
            blurb   => qq|The new official beginning of Route 66. Some say it's ridiculous. The road itself never began here. I say it's perfect. The opening image of a story should be a bookend, a mirror for the closing image of the story. The story of Route 66 ends at a pier. Now it begins at a pier, too. Maybe someday I'll set up a little shack here, and sell this book from it.|,
        },
        {
            name    => "Billy Goat Tavern",
            address => "Lower 430 North, N Michigan Ave, Chicago IL",
            blurb   => qq||,
        },
        {
            name    => "Ohio House Motel",
            address => "600 N La Salle Dr, Chicago IL",
            blurb   => qq|Room 110 has a hidden secret behind the mirror. Find out more by searching for "Room Attack" on Wasteland Firebird's YouTube channel.|,
        },
        {
            name    => "Cloud Gate mirrored bean sculpture",
            address => "201 E Randolph St, Chicago IL",
            blurb   => qq|Most people who travel Route 66 will only travel it once. So pay attention to the story that the road tells you.|,
        },
        {
            name    => "Chicago Athletic Association",
            address => "12 S Michigan Ave, Chicago IL",
            blurb   => qq|A cool, luxurious, renovated old hotel that has retained some of its sports club roots.|,
        },
        {
            name    => "Art Institute of Chicago",
            address => "111 S Michigan Ave, Chicago IL",
            blurb   => qq|Monet's every stroke contains frivolity. He used to say, "I like to paint as a bird sings." Viewing a Monet is an active process. You can't properly appreciate a Monet while seated. You have to approach the painting, then step back, then look away, then look back. A work by Monet is a three dimensional object, just as much a sculpture as a painting. Van Gogh was a better artist, but Monet had more fun.|,
        },
        {
            name    => "Historic Route 66 sign",
            address => "E Adams St & S Michigan Ave, Chicago IL",
            blurb   => qq|As you listen to the story of the road, you're also writing your own story. And you're the main character! Stand up tall, proud, and curious. You've been waiting your whole life for this. A good story can change you. A good story can change the world.|,
        },
        {
            name    => "Lou Mitchell's",
            address => "565 W Jackson Blvd, Chicago IL",
            blurb   => qq|Route 66 is more than just a road. It's more than just a fun vacation. Route 66 represents the idea of going West in search of a better life. Route 66 represents the American Dream.|,
        },
        {
            name    => "Lulu's Hot Dogs",
            address => "1000 S Leavitt St, Chicago IL",
            blurb   => qq|You won't be able to eat everything you see on the Route. I still haven't eaten here. Whether you eat at these places or not, stop in, say hello, and drop a tip in the jar. The food itself doesn't always matter. I put places on this list because they're beautiful, quirky, old, luxurious, or delicious. They don't have to be all of those things at once.|,
        },
        {
            name    => "Steak 'n Egger",
            address => "5647 Ogden Ave, Cicero IL",
            blurb   => qq||,
        },
        {
            name    => "Henry's Drive-In",
            address => "6031 Ogden Ave, Cicero IL",
            blurb   => qq||,
        },
        {
            name    => "Cigars & Stripes BBQ Lounge",
            address => "6715 Ogden Ave, Berwyn IL",
            blurb   => qq|There is a "Muffler Man" here, the first of many. It's important that you learn what a Muffler Man is. These are giant, human-shaped fiberglass sculptures. They dotted the landscape of mid-Twentieth century America. They sometimes held mufflers in their hands. Some are old, some are new. Wait till you see Atlanta Illinois and Tulsa Oklahoma.|,
        },
        {
            name    => "Dell Rhea's Chicken Basket",
            address => "645 Joliet Rd, Willowbrook IL",
            blurb   => qq|See what I mean, when I say you can't eat everything you see? How many restaurants have we passed already, six? Go in and leave them a tip anyway.|,
        },
        {
            name    => "White Fence Farm Restaurant",
            address => "1376 Joliet Rd, Romeoville IL",
            blurb   => qq||,
        },
        {
            name    => "Old Joliet Prison",
            address => "1125 Collins St, Joliet IL",
            blurb   =>
qq|We can't talk about Joliet Prison without talking about The Blues Brothers. That film is an archive of Americana. The music in that film spanned the entire Twentieth Century. Cab Calloway started making music in 1927, the year Angel Delgadillo was born, and one year after Route 66 came into being. Due to swift advances in music and communication technology, the Twentieth Century spawned a new genre of music every single decade. When was the last time you heard a truly new genre of music?|,
        },
        {
            name    => "Rialto Square Theatre",
            address => "102 N Chicago St, Joliet IL",
            blurb   => qq|Look at all the light bulbs on these old theaters.|,
        },
        {
            name    => "Blues Brothers Copmobile",
            address => "2410 S Chicago St, Joliet IL",
            blurb   => qq|My favorite scene in The Blues Brothers is when they park their car at the end of a narrow alley, in a tiny electrical closet just a few inches wider than the car itself. This was originally supposed to be an explanation of how the car got its supernatural powers. I always saw it as a humorous but accurate depiction of the hassles of city parking. If you have no idea what scene I'm talking about, that could be because it was cut from some versions of the film.|,
        },
        {
            name    => "Gemini Giant",
            address => "201 Bridge St, Wilmington IL",
            blurb   => qq|Another Muffler Man. Get out and get a close look at his metal-flake suit.|,
        },
        {
            name    => "Polk-A-Dot Drive In",
            address => "222 N Front St, Braidwood IL",
            blurb   => qq||,
        },
        {
            name    => "The Shop on Route 66",
            address => "315 N Center St, Gardner IL",
            blurb   => qq||,
        },
        {
            name    => "Gothic Church Dwight Townhall",
            address => "201 N Franklin St, Dwight IL",
            blurb   => qq||,
        },
        {
            name    => "80s Car Museum",
            address => "316 W Waupansie St, Dwight IL",
            blurb   => qq|In the 80s, we were pretty sure that modern cars would not be loved and preserved like the cars from the glory days of the 50s, 60s, and 70s. Safety and fuel economy were making cars boring. Or at least, that's what we thought. Nowadays, these 80s cars seem quirky and fun compared to the nondescript blobs that silently and cleanly traverse the interstates that parallel Route 66.|,
        },
        {
            name    => "Dwight Coin Laundry",
            address => "404 W Waupansie St, Dwight IL",
            blurb   => qq||,
        },
        {
            name    => "Ambler's Texaco Gas Station",
            address => "W Waupansie St, Dwight IL",
            blurb   => qq||,
        },
        {
            name    => "Standard Oil Gas Station",
            address => "400 S West St, Odell IL",
            blurb   => qq||,
        },
        {
            name    => "Old Log Cabin restaurant",
            address => "18700 Old Rte 66, Pontiac IL",
            blurb   => qq|I think you can get a piece of cherry pie here. I'm always looking for a good piece of cherry pie. That was meant to be taken literally but I guess you can take it figuratively if that amuses you.|,
        },
        {
            name    => "Route 66 Association of Illinois",
            address => "110 W Howard St, Pontiac IL",
            blurb   => qq|Bob Waldmire was a Route 66 artist. His name is one of the names you should learn and remember during this trip. His orange Volkswagen bus is here. His "Land Yacht" school bus is also here, sometimes. In 2024, by sheer chance, I ended up here right on one of the rare days that the bus was here and the interior was open to the public. I put some video of the Land Yacht up on YouTube. Search for "Wasteland Firebird Route 66."|,
        },
        {
            name    => "Pontiac Oakland Auto Museum",
            address => "205 N Mill St, Pontiac IL",
            blurb   => qq|My name is Wasteland Firebird because I own a 1975 Pontiac Firebird Trans Am, and I drive it around in the wasteland. I came here from an alternate timeline where a near-apocalyptic event happened in the year 1981. I came here to tell you that you don't know how good you have it.|,
        },
        {
            name    => "Wally's",
            address => "1 Holiday Rd, Pontiac IL",
            blurb   => qq|The first couple of times that I saw this place, I drove right by it. I figured there was no way it could be as good as Buc-ee's. Don't make the same mistake I did.|,
        },
        {
            name    => "Route 66 of Chenoa Roadside Attraction Tourist Info",
            address => "501 W Cemetery Ave, Chenoa IL",
            blurb   => qq|Normally, this is just a little closet full of flyers. But every time I come by, I populate it with t-shirts, books, or art. There's a little sign that says you're supposed to call a number for permission to leave stuff here. I've never called it.|,
        },
        {
            name    => "Lexington Route 66 Memory Lane",
            address => "Parade Rd, Lexington IL",
            blurb   => qq|Entropy cannot be stopped. The Route is crumbling before our eyes. There are some nostalgic signs here. But this section used to be covered in beautiful trees. Now it's just a bare stretch of road. I got some video of this spot with all of its trees back in 2024, you can find it on my YouTube channel.|,
        },
        {
            name    => "The Shake Shack",
            address => "512 W Main St, Lexington IL",
            blurb   => qq|I'm pretty sure I had some fried corn nuggets here. Corn nuggets are my favorite bit of semi-obscure American food. If this place is closed, don't worry, you'll have another chance try fried corn nuggets on this trip.|,
        },
        {
            name    => "Sprague's Super Service Station",
            address => "305 Pine St, Normal IL",
            blurb   => qq|Just knock if it's dark out when you arrive. There might still be someone there.|,
        },
        {
            name    => "Carl's Ice Cream Factory",
            address => "1700 W College Ave, Normal IL",
            blurb   => qq|Two muffler People of unmatched size live here. I refer to them as Small Carl and Large Marge.|,
        },
        {
            name    => "Funks Grove Pure Maple Sirup Farm",
            address => "Funks Grove Township IL",
            blurb   => qq|When traveling, you might think you have little need for maple syrup. But think a little harder. Most restaurants give you the fake stuff nowadays. Wouldn't it be good to have your own supply of the good stuff? And what if you run out of coolant or wiper fluid? I'm sure maple syrup would work fine for that. You can also just buy a really small piece of candy made out of syrup.|,
        },
        {
            name    => "Arcadia America's Playable Arcade Museum",
            address => "107 S Hamilton St, McLean IL",
            blurb   => qq|I'm an expert at playing those Ms. Pac Man machines where they flip a switch, or swap a chip, that makes Ms. Pac Man go extra fast. Be sure to check out their pinball place across the street, too.|,
        },
        {
            name    => "Country-Aire Restaurant",
            address => "606 E South St, Atlanta IL",
            blurb   => qq|A Muffler Woman with a pie lives here.|,
        },
        {
            name    => "American Giants Museum",
            address => "100 SW St, Atlanta IL",
            blurb   => qq|Not all of Route 66 is crumbling. Some of it is being revived. This place is a museum of Muffler People. Joel Baker is another name you should know. He's been obsessed with these giants for his entire life. He researches, finds, buys, restores, and sells them. And he makes YouTube videos about the whole process. Some of the giants at this museum belong to him.|,
        },
        {
            name    => "Hot Dog Muffler Man",
            address => "112 SW Arch St, Atlanta IL",
            blurb   => qq||,
        },
        {
            name    => "The Mill Museum",
            address => "738 S Washington St, Lincoln IL",
            blurb   => qq||,
        },
        {
            name    => "Wild Hare Cafe",
            address => "104 Governor Oglesby St, Elkhart IL",
            blurb   => qq||,
        },
        {
            name    => "The Old Station",
            address => "117 Elm St, Williamsville IL",
            blurb   => qq||,
        },
        {
            name    => "Outkast Tattoo Studio",
            address => "2828 N Peoria Rd, Springfield IL",
            blurb   => qq||,
        },
        {
            name    => "Illinois State Fair Route 66 Experience",
            address => "801 E Sangamon Ave, Springfield IL",
            blurb   => qq|Go at night. Drive around it. Some gates are sometimes closed, other gates are sometimes open. There is a custom brick here from Wasteland Firebird.|,
        },
        {
            name    => "Route 66 Hotel Conference Center",
            address => "625 E St Joseph St, Springfield IL",
            blurb   => qq|There is a secret hidden behind the mirror in Room 163. Find out more by searching for "Room Attack" on Wasteland Firebird's YouTube channel.|,
        },
        {
            name    => "Shea's Filling Station",
            address => "2075 N Peoria Rd, Springfield IL",
            blurb   => qq||,
        },
        {
            name    => "Maid-Rite",
            address => "118 N Pasfield St, Springfield IL",
            blurb   => qq||,
        },
        {
            name    => "Pharmacy Gallery Art Space",
            address => "623 E Adams St, Springfield IL",
            blurb   => qq|They tell me there's a Bob Waldmire exhibit here, Fridays and Saturdays in 2026.|,
        },
        {
            name    => "Springfield Southeast High School",
            address => "2350 E Ash St, Springfield IL",
            blurb   => qq|Go here to find the Spartan Viking Muffler Man.|,
        },
        {
            name    => "Mel-O-Cream Donuts",
            address => "217 E Laurel St, Springfield IL",
            blurb   => qq||,
        },
        {
            name    => "Ace Sign Co.",
            address => "2540 S 1st St, Springfield IL",
            blurb   => qq|This place is pretty nondescript on the outside. They really do make signs here. But there's also a sign museum. I still need to visit this place when it's open.|,
        },
        {
            name    => "Charlie Parker's Diner",
            address => "700 W North St, Springfield IL",
            blurb   => qq||,
        },
        {
            name    => "Lauterbach Muffler Man",
            address => "1569 Wabash Ave, Springfield IL",
            blurb   => qq||,
        },
        {
            name    => "Pinky Elephant with Martini",
            address => "2723 S 6th St, Springfield IL",
            blurb   => qq|For some reason, Route 66 has a fascination with pink elephants. This isn't the only one.|,
        },
        {
            name    => "Cozy Dog",
            address => "2935 S 6th St, Springfield IL",
            blurb   => qq|This place is still owned by the Waldmire family. Bob Waldmire's works are all over the walls. You might even find something by Wasteland Firebird on the flyer rack.|,
        },
        {
            name    => "Route 66 Motorheads Bar and Grill",
            address => "600 Toronto Rd, Springfield IL",
            blurb   => qq|Big Ron the extra-big Muffler Man is here.|,
        },
        {
            name    => "Chatham Railroad Museum",
            address => "100 N State St, Chatham IL",
            blurb   => qq||,
        },
        {
            name    => "Illinois Brick Road",
            address => "4995-4790 Snell Rd, Auburn IL",
            blurb   => qq|The road is made of bricks. Old, original Route 66 bricks.|,
        },
        {
            name    => "Sly Fox Bookstore",
            address => "123 N Springfield St, Virden IL",
            blurb   => qq||,
        },
        {
            name    => "Doc's Just Off 66",
            address => "133 S 2nd St, Girard IL",
            blurb   => qq||,
        },
        {
            name    => "Whirl A Whip",
            address => "309 S 3rd St, Girard IL",
            blurb   => qq||,
        },
        {
            name    => "Turkey Tracks",
            address => "26618-27306 Donaldson Rd, Girard IL",
            blurb   => qq|A bird ran through the wet concrete, and its footprints are still there. Look for a small sign and a white square on the road.|,
        },
        {
            name    => "Skyview Drive-In",
            address => "1500 Old Rte 66 N, Litchfield IL",
            blurb   => qq||,
        },
        {
            name    => "Niehaus Cycle Sales",
            address => "718 Old Rte 66 N, Litchfield IL",
            blurb   => qq||,
        },
        {
            name    => "The Ariston Cafe",
            address => "413 Old Rte 66 N, Litchfield IL",
            blurb   => qq||,
        },
        {
            name    => "Litchfield Museum",
            address => "334 Old Rte 66 N, Litchfield IL",
            blurb   => qq||,
        },
        {
            name    => "Soulsby Service Station",
            address => "710 W 1st St, Mt Olive IL",
            blurb   => qq|When I first saw this place, I stood outside and enjoyed the fact that it existed. Then I turned and walked away. But my traveling companion tried the door, and found it open. You're free to walk around alone in here. It's a profound experience, knowing that someone you don't know trusts you, and knowing that they put all of this here for you.|,
        },
        {
            name    => "Henry's Rabbit Ranch",
            address => "1107 Historic Old Rte 66, Staunton IL",
            blurb   => qq|At some point you're going to figure out that not everything on this list is still open for business. We're just lucky that these places still exist at all.|,
        },
        {
            name    => "DeCamp Station",
            address => "8767 State Rte 4, Staunton IL",
            blurb   => qq||,
        },
        {
            name    => "Pink Elephant Antique Mall",
            address => "908 Veterans Memorial Dr, Livingston IL",
            blurb   => qq|I told you there'd be more pink elephants. There's a wild collection of Muffler People and other Muffler Species here. Maybe even some Muffler Aliens.|,
        },
        {
            name    => "Route 66 Creamery",
            address => "11 S Old Rte 66, Hamel IL",
            blurb   => qq|I've stopped here on two separate occasions, and met two completely different sets of employees. But they all had something in common. The employees here are the most pure, kind, well-adjusted, hard-working young people I've ever met. Hamel Illinois is America at its best.|,
        },
        {
            name    => "Weezy's",
            address => "108 Old Rte 66, Hamel IL",
            blurb   => qq||,
        },
        {
            name    => "Wildey Theatre",
            address => "252 N Main St, Edwardsville IL",
            blurb   => qq||,
        },
        {
            name    => "West End Service Station",
            address => "620 St Louis St, Edwardsville IL",
            blurb   => qq||,
        },
        {
            name    => "Luna Cafe",
            address => "201 E Chain of Rocks Rd, Granite City IL",
            blurb   => qq||,
        },
        {
            name    => "Old Chain of Rocks Bridge",
            address => "10820 Riverview Dr, St Louis MO",
            blurb   => qq|Nowadays you don't drive it. But you can go for a walk across it.|,
        },
        {
            name    => "O'Brien Tire & Auto Care",
            address => "3924 Nameoki Rd, Granite City IL",
            blurb   => qq|Earl the Mechanic Muffler Man is here. And when was the last time you had your oil changed?|,
        },
        {
            name    => "Mr. Twist Ice Cream",
            address => "2649 Madison Ave, Granite City IL",
            blurb   => qq||,
        },
        {
            name    => "It's Electric Neon Sign Park",
            address => "1300 19th St, Granite City IL",
            blurb   => qq||,
        },
        {
            name    => "Rusty the Muffler Man",
            address => "614 Niedringhaus Ave, Granite City IL",
            blurb   => qq|He might not be on your map, but if you go to this address, he's here.|,
        },
        {
            name    => "Crown Candy Kitchen",
            address => "1401 St Louis Ave, St Louis MO",
            blurb   => qq|If we see the journey down Route 66 as a story, we're breaking into Act II. The hero accepts the call to adventure! Not all of this journey will be fun and games. Sometimes you'll have to go through a bad part of town to get to a good part of town. Are you ready for adventure? The Crown Candy Kitchen is all about fat and sugar.|,
        },
        {
            name    => "Chili Mac's Diner",
            address => "510 Pine St, St Louis MO",
            blurb   => qq|The St. Louis Arch is known as "The Gateway to the West." Manifest Destiny was the idea that God wanted the Europeans to spread out into America. I don't think that any supernatural being really cared where Europeans ended up living. And there were some people living here already. The Europeans did some bad things to those people. But ultimately, we all came together to make the best country on Earth.|,
        },
        {
            name    => "Neon Museum of St Louis",
            address => "3537 Chouteau Ave, St Louis MO",
            blurb   => qq|When I say the USA is the best country on Earth, you might reply that I'm biased since I was born in the USA. But I've traveled the world and I've spent a lot of time doing my best to overcome my biases. I firmly believe that America has things about it that make it truly exceptional.|,
        },
        {
            name    => "Donut Drive In",
            address => "6525 Chippewa St, St Louis MO",
            blurb   => qq|America was the first country on Earth where your social class didn't matter. It didn't matter who you knew or who your parents were. All that mattered was what you were capable of. If you were hard-working, creative, passionate, skilled, talented, good at marketing, good at networking, able to see things through, and willing to risk it all, you'd almost certainly succeed. That's the American Dream.|,
        },
        {
            name    => "Ted Drewes Frozen Custard",
            address => "6726 Chippewa St, St Louis MO",
            blurb   => qq||,
        },
        {
            name    => "Wally's",
            address => "950 Assembly Pkwy, Fenton MO",
            blurb   => qq||,
        },
        {
            name    => "The Malt Shop",
            address => "1751 Smizer Station Rd, Fenton MO",
            blurb   => qq|Don't ever just order a milkshake. Always ask for a malt. For some reason malts are slowly being forgotten. They're harder to find now. The "malt" is just powdered barley extract but it adds a great bit of flavor.|,
        },
        {
            name    => "Route 66 State Park",
            address => "97 N Outer Rd, Eureka MO",
            blurb   => qq||,
        },
        {
            name    => "Campbell's Service",
            address => "18625 Historic Rte 66, Pacific MO",
            blurb   => qq||,
        },
        {
            name    => "Red Cedar Inn Museum and Visitor Center",
            address => "1047 E Osage St, Pacific MO",
            blurb   => qq||,
        },
        {
            name    => "Hoffman's Drive-In",
            address => "306 S 1st St, Pacific MO",
            blurb   => qq||,
        },
        {
            name    => "Gardenway Motel sign",
            address => "2827 MO-100, Villa Ridge MO",
            blurb   => qq|It's just a sign now. But oh, what a sign it is.|,
        },
        {
            name    => "Old Sunset Motel",
            address => "976 Osage Villa Ct, Villa Ridge MO",
            blurb   => qq||,
        },
        {
            name    => "International Shoe Company Building",
            address => "160 N Main St, St Clair MO",
            blurb   => qq||,
        },
        {
            name    => "Creative Chainsaw Carvings",
            address => "151 State Rte W, Sullivan MO",
            blurb   => qq|Ask her about her dead husband. You will never forget her story.|,
        },
        {
            name    => "Meramec Caverns",
            address => "1135 Hwy W, Sullivan MO",
            blurb   => qq|Some people go for the nature stuff. I'm more into the midcentury Americana. But I figured this place was obligatory, so I went. I didn't expect to walk out in tears. Not only is the place gorgeous, but at the end, they project a patriotic short film about America on the cavern walls.|,
        },
        {
            name    => "Terror On Route 66",
            address => "1143 N Service Rd W, Sullivan MO",
            blurb   => qq|I've been meaning to check this place out, but I'm too scared.|,
        },
        {
            name    => "Shamrock Court Motel",
            address => "101 Shamrock, Sullivan MO",
            blurb   => qq|Newly restored by Route 66 hero Roamin' Rich Dinkela.|,
        },
        {
            name    => "Missouri Hick Barbeque",
            address => "913 E Washington Blvd, Cuba MO",
            blurb   => qq||,
        },
        {
            name    => "Wagon Wheel Motel",
            address => "901 E Washington Blvd, Cuba MO",
            blurb   => qq|You can hear the neon sign buzz on and off. This property is now owned by the magnificent steward known as Roamin' Rich Dinkela.|,
        },
        {
            name    => "Weir on 66 Rich's Famous Burgers",
            address => "102 W Washington St, Cuba MO",
            blurb   => qq|This old building has been many things throughout the years. Go in and buy some of whatever it is they're selling these days.|,
        },
        {
            name    => "Fanning Outpost Rocking Chair",
            address => "5957 State Hwy ZZ, Cuba MO",
            blurb   => qq|Say hi to Fluffy the cat. If you pet her long enough, she'll climb into your lap.|,
        },
        {
            name    => "Mule Trading Post",
            address => "11160 Dillon Outer Rd, Rolla MO",
            blurb   => qq|I'm not claiming this place is open. I'm just claiming it's worth stopping at. Check out those signs.|,
        },
        {
            name    => "Vernelle's Motel",
            address => "10887 Arlington Road, Newburg MO",
            blurb   => qq|Entropy cannot be stopped. We can only delay it for a while.|,
        },
        {
            name    => "John's Modern Cabins",
            address => "11107 Arlington Outer Rd, Newburg MO",
            blurb   => qq||,
        },
        {
            name    => "Devil's Elbow Bridge",
            address => "Big Piney River, Devils Elbow MO",
            blurb   => qq||,
        },
        {
            name    => "Uranus Fudge Factory",
            address => "14400 State Hwy Z, St Robert MO",
            blurb   => qq|My notes describe the giant here as the "Mega Mayor Patriot Golfer Muffler Man." I'm not sure I got his name right, but go take a look and tell me that name doesn't fit him. Here's a tip. If you pronounce it YER-uh-nuss you'll ruin all of their jokes.|,
        },
        {
            name    => "Route 66 Diner",
            address => "126 St Robert Blvd, St Robert MO",
            blurb   => qq|I hung some of my art on the wall here, next to the kids' art. Maybe it's still there.|,
        },
        {
            name    => "Route 66 Neon Sign Park",
            address => "133 Reed Pkwy, St Robert MO",
            blurb   => qq||,
        },
        {
            name    => "Old Stagecoach Stop",
            address => "106 N Lynn St, Waynesville MO",
            blurb   => qq|It's not just a building. It's the oldest building in the USA.|,
        },
        {
            name    => "Gascozark Store",
            address => "30568 State Hwy AB, Richland MO",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Gasconade Bridge",
            address => "Richland MO",
            blurb   => qq||,
        },
        {
            name    => "Munger Moss Motel",
            address => "1336 US Rt 66, Lebanon MO",
            blurb   => qq|The organization that is restoring the sign is different from the organization that runs the motel, and the motel isn't exactly a motel because it's more like apartments, but they tell me that might be changing, and maybe you can stay here like it's a motel again. I dunno, just go look at the sign.|,
        },
        {
            name    => "Smokin' Jones BBQ Wrink's Market",
            address => "135 Wrinkle Ave, Lebanon MO",
            blurb   => qq|You can get a piece of cherry pie here.|,
        },
        {
            name    => "Taylor's Dairy Joy",
            address => "1205 US Rte 66, Lebanon MO",
            blurb   => qq||,
        },
        {
            name    => "The Manor Inn",
            address => "505 E Elm St, Lebanon MO",
            blurb   => qq||,
        },
        {
            name    => "Boswell Park Camp Joy",
            address => "51 Drury Ln, Lebanon MO",
            blurb   => qq|I'm not here to tell you what things are. I'm here to tell you where to go. Ask questions, read the plaques, or just drive by and enjoy.|,
        },
        {
            name    => "Redmon's Candy Factory",
            address => "330 Pine St, Phillipsburg MO",
            blurb   => qq||,
        },
        {
            name    => "Little Clay House",
            address => "238 N Clay St, Marshfield MO",
            blurb   => qq|I haven't actually been to this place, but it looks nice.|,
        },
        {
            name    => "Buc-ee's",
            address => "3284 N Mulroy Rd, Springfield MO",
            blurb   => qq|Ah, here we are. Buc-ee's started in Texas but now has many locations. The company has only existed since 1982, but I'm sure that in 2082, future Route travelers will consider this place a magnificent historical landmark.
Buc-ee's is privately held, so they can focus on customer happiness without worrying about short-term shareholder profits.|,
        },
        {
            name    => "Rest Haven Court",
            address => "2000 E Kearney St, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Andy's Frozen Custard",
            address => "2119 N Glenstone Ave, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Glenstone Court Motel",
            address => "2023 N Glenstone Ave, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Best Western Route 66 Rail Haven",
            address => "203 S Glenstone Ave, Springfield MO",
            blurb   => qq|They have some cool old signs here.|,
        },
        {
            name    => "Steak 'n Shake",
            address => "1158 E St Louis St, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Gillioz Theatre",
            address => "325 Park Central E, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "History Museum on the Square",
            address => "154 Park Central Square, Springfield MO",
            blurb   => qq|Some museums on the Route are just a bunch of flat images blown up so big you can see the pixels. I call these "flat museums." They're funded with multimillion dollar taxpayer-funded grants, while the Route's legacy small businesses are dying. But at this museum, you can find the original telegram from Cyrus Avery on April 30, 1926 declaring that the Route would be known as "66."|,
        },
        {
            name    => "1984 Arcade",
            address => "400 S Jefferson Ave, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Rogue Barber Co. & D's Wax Factory",
            address => "639 W Walnut St, Springfield MO",
            blurb   => qq|It's a historic building. If you don't have any hair on your head, go in and get something waxed.|,
        },
        {
            name    => "College Street Cafe",
            address => "1622 W College St, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Car Museum",
            address => "1634 W College St, Springfield MO",
            blurb   => qq|I heard this place might close soon. Enjoy it while you can.|,
        },
        {
            name    => "Rockwood Motor Court",
            address => "2200 W College St, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Route 66 KOA Holiday",
            address => "5775 W Farm Rd 140, Springfield MO",
            blurb   => qq||,
        },
        {
            name    => "Gary's Gay Parita Sinclair",
            address => "21118 Old 66, Ash Grove MO",
            blurb   => qq|I think there's still a signed copy of my book, Heads Will Rock: A chronicle of postapocalyptic mayhem hidden in this place. It's free for the taking. It's about a postapocalyptic journey up Route 66, to recommission the old destroyed Pontiac Firebird factory in Norwood Ohio.|,
        },
        {
            name    => "Spencer Station",
            address => "19720 Lawrence 2062, Miller MO",
            blurb   => qq||,
        },
        {
            name    => "Red Oak II",
            address => "12275 Kafir Rd, Carthage MO",
            blurb   => qq||,
        },
        {
            name    => "Campbell 66 Express",
            address => "426 High St, Carthage MO",
            blurb   => qq||,
        },
        {
            name    => "Boots Court Motel",
            address => "125 S Garrison Ave, Carthage MO",
            blurb   => qq||,
        },
        {
            name    => "66 Drive In",
            address => "17231 Old 66 Blvd, Carthage MO",
            blurb   => qq||,
        },
        {
            name    => "SuperTam on 66",
            address => "221 W Main St, Carterville MO",
            blurb   => qq|Some places have been many things through the years, but they're usually only one thing at a time. This place is many things at a time. Something about Superman and ice cream.|,
        },
        {
            name    => "Route 66 Center",
            address => "112 W Broadway St, Webb City MO",
            blurb   => qq||,
        },
        {
            name    => "Granny Shaffer's Restaurant",
            address => "2728 N Rangeline Rd, Joplin MO",
            blurb   => qq||,
        },
        {
            name    => "Royale Cinema Lounge",
            address => "715 E Broadway St, Joplin MO",
            blurb   => qq||,
        },
        {
            name    => "Wilder's Steakhouse",
            address => "1216 S Main St, Joplin MO",
            blurb   => qq||,
        },
        {
            name    => "Cars on the Route Kan-O-Tex Service Station",
            address => "199 N Main St, Galena KS",
            blurb   => qq|The vehicular inspiration for Tow Mater, the tow truck from Pixar's Cars, is here.|,
        },
        {
            name    => "Gearhead Curios",
            address => "520 Main St, Galena KS",
            blurb   => qq|Things are about to get weird. Route 66 is not just a road anymore. Nowadays, Route 66 is a collective project to preserve, restore, and revive the art, architecture, and history of mid-Twentieth century America. Aaron Perry from Gearhead Curios understands this far better than most.|,
        },
        {
            name    => "Galena Mining & Historical Museum",
            address => "319 W 7th St, Galena KS",
            blurb   => qq||,
        },
        {
            name    => "Old Riverton Store",
            address => "7109 KS-66, Riverton KS",
            blurb   => qq||,
        },
        {
            name    => "Rainbow Bridge",
            address => "SE Beasley Rd, Baxter Springs KS",
            blurb   => qq||,
        },
        {
            name    => "Baxter Springs Heritage Center & Museum",
            address => "740 East Ave, Baxter Springs KS",
            blurb   => qq|I haven't actually checked this place out yet, but I've seen photos of a freaky painting of a gunfight that lives here. I gotta see this one in person.|,
        },
        {
            name    => "Route 66 Visitors Center",
            address => "940 Military Ave, Baxter Springs KS",
            blurb   => qq||,
        },
        {
            name    => "Dallas' Dairyette",
            address => "103 N Main St, Quapaw OK",
            blurb   => qq|In my video "Route 66 from Carthage to Catoosa, April 16, 2025," I asked six middle-school students if they'd ever heard of the American Dream. They all said no. I hope that was because they're like fish who don't know that they're swimming in something called "water." Even so, we must teach the next generation not to take prosperity for granted. Poverty and suffering is humanity's default state. Wealth and happiness is a rare exception in human history.|,
        },
        {
            name    => "Dairy King",
            address => "100 N Main St, Commerce OK",
            blurb   =>
qq|The current owners took over this place in 1980 and I don't think their prices have changed since. Last time I was here, the lady accidentally charged me \$2.50 for an \$8.50 order. When I pointed out the error, she used a calculator to determine the amount I still had left to pay. But if I'm ever lucky enough to reach her age, I'll be satisfied if I have half of her mental acuity. Her elderly son gets up every day at 3am to run 10 miles, and he rides around in the only car ever offered with a factory flame job: a Chrysler PT Cruiser.|,
        },
        {
            name    => "Waylan's Ku-Ku",
            address => "915 N Main St, Miami OK",
            blurb   => qq||,
        },
        {
            name    => "Coleman Theater",
            address => "103 N Main St, Miami OK",
            blurb   => qq|It's a gorgeous, old, zillion-dollar theater in the middle of nowhere.|,
        },
        {
            name    => "Route 66 Sidewalk Hwy",
            address => "S 540 Rd, Miami OK",
            blurb   => qq|I wouldn't recommend actually driving down this piece of original road, but go take a look at it.|,
        },
        {
            name    => "Crosstar Flag and Tag Museum",
            address => "103 S Central Ave, Afton OK",
            blurb   => qq|Some things are better left unexplained.|,
        },
        {
            name    => "Clanton's Cafe",
            address => "319 E Illinois Ave, Vinita OK",
            blurb   => qq|I haven't tried the food here yet, but any restaurant with a giant sign that just says "EAT" on it gets to be in this book.|,
        },
        {
            name    => "Center Theater",
            address => "124 S Wilson St, Vinita OK",
            blurb   => qq||,
        },
        {
            name    => "Hi-Way Cafe Western Motel",
            address => "437918 US-60, Vinita OK",
            blurb   => qq|Big Bill the Muffler Man, the Big Indian, and Big Al the Chef are all here.|,
        },
        {
            name    => "Pryor Creek Bridge",
            address => "Chelsea OK",
            blurb   => qq||,
        },
        {
            name    => "Ed Galloway's Totem Pole Park",
            address => "21300 OK-28A, Chelsea OK",
            blurb   => qq|One man's weird way of paying tribute to the First Nations peoples of the Americas.|,
        },
        {
            name    => "Annie's Diner",
            address => "12015 Poplar St, Claremore OK",
            blurb   => qq|It's closed now, but I did get some good corn nuggets here once.|,
        },
        {
            name    => "J.M. Davis Arms & Historical Museum",
            address => "330 N JM Davis Blvd, Claremore OK",
            blurb   => qq|If you're visiting from some un-American place where you can't have guns, be sure to check this place out.|,
        },
        {
            name    => "Blue Whale of Catoosa",
            address => "2600 OK-66, Catoosa OK",
            blurb   => qq|It's a big blue whale. It looks good at night. It might still be under renovation, but you can see it from the road.|,
        },
        {
            name    => "Desert Hills Motel",
            address => "5220 E 11th St, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "Tally's Good Food Cafe",
            address => "1102 S Yale Ave, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "Coney I-Lander",
            address => "2838 E 11th St, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "The Campbell Hotel",
            address => "2636 E 11th St, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "Ike's Chili",
            address => "1503 E 11th St, Tulsa OK",
            blurb   => qq|Tulsa is a neon revival town. Try to see the signs at night.|,
        },
        {
            name    => "Buck Atom's Cosmic Curios on 66",
            address => "1347 E 11th St, Tulsa OK",
            blurb   => qq|Mary Beth Babcock is another name you should remember. She's at the center of the modern-day Route 66 revival. She's the dreamer behind the long strip of Muffler Men in Tulsa now known as the Land of the Giants. Buck Atom. Stella Atom. Cowboy Bob. Rosie the Riveter. Meadow Gold Mack.|,
        },
        {
            name    => "Buck's Vintage",
            address => "1317 E 11th St, Tulsa OK",
            blurb   => qq|A carefully curated collection of the coolest vintage stuff you'll ever find. Wasteland Firebird has an engraved brick at the base of Cowboy Bob.|,
        },
        {
            name    => "Meadow Gold Mack",
            address => "1306 E 11th St, Tulsa OK",
            blurb   => qq|Great work from local artists.|,
        },
        {
            name    => "Toynbee Tile",
            address => "E 6th St & S Boston Ave, Tulsa OK",
            blurb   => qq|Cross in the crosswalks, looking down at the ground. There is a small linoleum mosaic embedded in the asphalt. Mosaics like these have been mysteriously appearing in cities around the world since the early 80s. I'd make a documentary about them, but someone already did. It's called Resurrect Dead: The Mystery of the Toynbee Tiles.|,
        },
        {
            name    => "Cyrus Avery Centennial Plaza",
            address => "Southwest Blvd, Tulsa OK",
            blurb   => qq|I rarely say this. But, what a sculpture.|,
        },
        {
            name    => "Route 66 Neon Sign Park",
            address => "1450 Southwest Blvd, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Historical Village",
            address => "3770 Southwest Blvd, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "Ollie's Station",
            address => "4070 Southwest Blvd, Tulsa OK",
            blurb   => qq||,
        },
        {
            name    => "The Roller Dome",
            address => "9661 New Sapulpa Rd, Sapulpa OK",
            blurb   => qq|There is a gorgeous old hand-painted sign out front.|,
        },
        {
            name    => "Happy Burger",
            address => "215 N Mission St, Sapulpa OK",
            blurb   => qq||,
        },
        {
            name    => "Gasoline Alley Classics",
            address => "24 N Main St, Sapulpa OK",
            blurb   => qq|There's a friendly competition going on between Michael Jones of Gasoline Alley Classics and Aaron Perry of Gearhead Curios to have the best bathroom on Route 66. Everyone agrees that the third best is Buc-ee's.|,
        },
        {
            name    => "Heart of Route 66 Auto Museum",
            address => "13 Sahoma Lake Rd, Sapulpa OK",
            blurb   => qq||,
        },
        {
            name    => "Rock Creek Bridge",
            address => "W Ozark Trail, Sapulpa OK",
            blurb   => qq||,
        },
        {
            name    => "Tee Pee Drive-in",
            address => "13166 W Ozark Trail, Sapulpa OK",
            blurb   => qq||,
        },
        {
            name    => "J's Country Kitchen",
            address => "31 Oak St, Kellyville OK",
            blurb   => qq||,
        },
        {
            name    => "Bristow Train Depot Museum",
            address => "1 Railroad Pl, Bristow OK",
            blurb   => qq||,
        },
        {
            name    => "Rock Cafe",
            address => "114 W Main St, Stroud OK",
            blurb   => qq|Stroud is a neon revival town. Try to look at the signs at night.|,
        },
        {
            name    => "Route 66 Spirit of America Museum",
            address => "220 W Main St, Stroud OK",
            blurb   => qq|If you've been searching for the American Dream, you just found it.|,
        },
        {
            name    => "Skyliner Motel",
            address => "717 W Main St, Stroud OK",
            blurb   => qq|During The Great Route 66 Centennial Convergence, we sold out this place for the first time since its recent renovation.|,
        },
        {
            name    => "Route 66 Bowl",
            address => "920 E 1st St, Chandler OK",
            blurb   => qq||,
        },
        {
            name    => "Lincoln Motel",
            address => "740 E 1st St, Chandler OK",
            blurb   => qq||,
        },
        {
            name    => "McJerry's Route 66 Gallery",
            address => "306 Manvel Ave, Chandler OK",
            blurb   => qq|I think Jerry McClanahan used to write some kind of Route 66 guide, but the real reason to stop here is his amazing painting 666 EXPRESS.|,
        },
        {
            name    => "Westfall Phillips 66 Station",
            address => "701 Manvel Ave, Chandler OK",
            blurb   => qq||,
        },
        {
            name    => "Seaba Station Motorcycle Museum",
            address => "336992 E OK-66, Warwick OK",
            blurb   => qq||,
        },
        {
            name    => "John's Place Museum",
            address => "13441 OK-66, Arcadia OK",
            blurb   => qq||,
        },
        {
            name    => "Chicken Shack",
            address => "212 OK-66, Arcadia OK",
            blurb   => qq||,
        },
        {
            name    => "Arcadia Round Barn",
            address => "107 OK-66, Arcadia OK",
            blurb   => qq||,
        },
        {
            name    => "Pops 66",
            address => "660 OK-66, Arcadia OK",
            blurb   => qq|I'm a connoisseur of soda pop, and I highly recommend this place. If you don't know what to try, I'd suggest a Moxie. If you think it tastes like medicine, that's because it originally was medicine. And if you think moxie is a cool word to name a soda after, you've got it backwards. The soda came first.|,
        },
        {
            name    => "1889 Territorial School",
            address => "124 E 2nd St, Edmond OK",
            blurb   => qq||,
        },
        {
            name    => "Tower Theatre",
            address => "425 NW 23rd St, Oklahoma City OK",
            blurb   => qq||,
        },
        {
            name    => "Milk Bottle Grocery",
            address => "2426 N Classen Blvd, Oklahoma City OK",
            blurb   => qq||,
        },
        {
            name    => "Western Motel",
            address => "7600 NW 39th Expy, Bethany OK",
            blurb   => qq||,
        },
        {
            name    => "Lake Overholser Bridge",
            address => "8703-8709 Overholser Dr, Bethany OK",
            blurb   => qq||,
        },
        {
            name    => "Lakeview Market",
            address => "9025 N Overholser Dr, Yukon OK",
            blurb   => qq||,
        },
        {
            name    => "Yukon Mill Grain Co",
            address => "Yukon OK",
            blurb   => qq||,
        },
        {
            name    => "Ranger Motel",
            address => "1201 SE 27th St, El Reno OK",
            blurb   => qq||,
        },
        {
            name    => "Johnnie's Grill",
            address => "301 S Rock Island Ave, El Reno OK",
            blurb   => qq|Get the onion burger. But save room for three more.|,
        },
        {
            name    => "Robert's Grill",
            address => "300 S Bickford Ave, El Reno OK",
            blurb   => qq|Get the onion burger. But save room for two more.|,
        },
        {
            name    => "Sid's Diner",
            address => "300 S Choctaw Ave, El Reno OK",
            blurb   => qq|Get the onion burger. But save room for one more.|,
        },
        {
            name    => "Jobe's Country Boy Drive-In",
            address => "1220 Sunset Dr, El Reno OK",
            blurb   => qq|Get the onion burger.|,
        },
        {
            name    => "Indian Trading Post",
            address => "825 S Walbaum Rd, Calumet OK",
            blurb   => qq||,
        },
        {
            name    => "Bridgeport Bridge",
            address => "US-281, Hinton OK",
            blurb   => qq||,
        },
        {
            name    => "Hinton Junctions Courts and Cafe",
            address => "16153 Old 66 Rd, Hinton OK",
            blurb   => qq||,
        },
        {
            name    => "Lucille's Historic Highway Gas Station",
            address => "US Rte 66, Hydro OK",
            blurb   => qq||,
        },
        {
            name    => "The Big Astronaut",
            address => "N Broadway St, Weatherford OK",
            blurb   => qq|In the Twentieth Century, we traveled by horses, cars, airplanes, and space rockets, all in the same century. My grandfather saw it all. By the time we got to the moon landing, he refused to believe it was real. He wasn't a conspiracy theorist. His brain just couldn't grasp that such a thing was possible.|,
        },
        {
            name    => "The Glancy Motel",
            address => "217 W Gary Blvd, Clinton OK",
            blurb   => qq|There never was, and never will be, another century like the Twentieth. One day, historians will speak of "The Twentieth Century" the way we today speak of "The Renaissance," or "The Enlightenment."|,
        },
        {
            name    => "Cotton Boll Motel sign",
            address => "605 Old US Hwy 66, Canute OK",
            blurb   => qq||,
        },
        {
            name    => "United Supermarkets",
            address => "2700 W 3rd St, Elk City OK",
            blurb   => qq|A modern supermarket that honors the beauty of mid-Twentieth Century design.|,
        },
        {
            name    => "National Route 66 & Transportation Museum",
            address => "2717 W 3rd St, Elk City OK",
            blurb   => qq|It's a weird museum. But weird is good, right?|,
        },
        {
            name    => "Sandhill Curiosity Shop",
            address => "201 S Sheb Wooley Ave, Erick OK",
            blurb   => qq|Harley Russell is here. He was the human inspiration for the vehicular character Tow Mater from Pixar's Cars. They had to make a few changes to his personality, because it was a movie for kids.|,
        },
        {
            name    => "Sam's Town on 66",
            address => "401 W Roger Miller Blvd, Erick OK",
            blurb   => qq|When we were here, a dirt-encrusted man came down the street, handed us bags of fresh pecans still in their shells, then walked away. Maybe that was Sam?|,
        },
        {
            name    => "West Winds Motel",
            address => "617 W Roger Miller Blvd, Erick OK",
            blurb   => qq||,
        },
        {
            name    => "U-Drop Inn Cafe",
            address => "105 E 12th St, Shamrock TX",
            blurb   => qq|There is a message made of hand-cut plastic letters embedded into the asphalt in front of this building.|,
        },
        {
            name    => "Restored 1929 Route 66 Gas Station",
            address => "212 First St, McLean TX",
            blurb   => qq||,
        },
        {
            name    => "Cactus Inn",
            address => "101 Pine St, McLean TX",
            blurb   => qq||,
        },
        {
            name    => "Red River Steakhouse",
            address => "101 US Rte 66, McLean TX",
            blurb   => qq||,
        },
        {
            name    => "Alanreed",
            address => "Alanreed TX",
            blurb   => qq||,
        },
        {
            name    => "Jericho Gap",
            address => "5989 State Hwy 70, Clarendon TX",
            blurb   => qq||,
        },
        {
            name    => "Leaning Tower of Texas",
            address => "Groom TX",
            blurb   => qq|Why is it leaning? I dunno, it was probably aliens.|,
        },
        {
            name    => "Buc-ee's",
            address => "9900 E I-40, Amarillo TX",
            blurb   => qq|If you want to try something weird and American, something that even a lot of Americans haven't tried, look for a Chick-O-Stick. Peanut butter and toasted coconut, no chocolate. Fresh ones are better, so buy them from a high-traffic business like Buc-ee's. If they're crunchy, they're fresh. If they're chewy or sticky, they're stale.|,
        },
        {
            name    => "The Big Texan Steak Ranch & Brewery",
            address => "7701 I-40, Amarillo TX",
            blurb   => qq|Some places are just a gimmick, and that's fine. But this gimmick has some of the best food on the Route, and it's a great motel, too. Some say The Big Texan is not actually on Route 66. I say the Big Texan is like the Eiffel Tower. If I happened to be passing two blocks away from it, I'd make a point to stop by.|,
        },
        {
            name    => "Slug Bug Ranch",
            address => "1415 Sunrise Dr, Amarillo TX",
            blurb   => qq|A miniature version of the Cadillac Ranch. Bring some spray paint. You're allowed to paint the cars.|,
        },
        {
            name    => "Texas Route 66 Visitor Center",
            address => "1900 SW 6th Ave, Amarillo TX",
            blurb   => qq||,
        },
        {
            name    => "Elmo's Drive Inn",
            address => "2618 SW 3rd Ave, Amarillo TX",
            blurb   => qq|I thought this beautiful old joint was abandoned, but when I pulled in, friendly people appeared and came up to my car, ready to help. I'd just eaten, but I gave them enough money to buy free food for the next three customers.|,
        },
        {
            name    => "Lile Art Gallery",
            address => "2719 SW 6th Ave, Amarillo TX",
            blurb   => qq|In the old car factories in Detroit, paint used to build up in layers on the walls in the areas where they painted the cars. You could chip pieces off and polish them into beautiful multicolored "stones" called "Fordite." Spray paint builds up on the cars at the Cadillac Ranch, too. Bob Lile harvests this paint to create "Cadillite" jewelry.|,
        },
        {
            name    => "Smokey Joe's",
            address => "2903 SW 6th Ave, Amarillo TX",
            blurb   => qq||,
        },
        {
            name    => "GoldenLight Cafe & Cantina",
            address => "2906 SW 6th Ave, Amarillo TX",
            blurb   => qq||,
        },
        {
            name    => "Texas Ivy Antiques",
            address => "3511 SW 6th Ave, Amarillo TX",
            blurb   => qq||,
        },
        {
            name    => "The Handle Bar and Grill",
            address => "3514 SW 6th Ave, Amarillo TX",
            blurb   => qq||,
        },
        {
            name    => "Meme's Cafe",
            address => "3700 SW 6th Ave, Amarillo TX",
            blurb   => qq||,
        },
        {
            name    => "2nd Amendment Cowboy Muffler Man",
            address => "2601 Hope Rd, Amarillo TX",
            blurb   => qq|Just beside the Cadillac Ranch, there's a Muffler Man with opinions about what an awesome document the Bill of Rights is.|,
        },
        {
            name    => "Cadillac Ranch",
            address => "13651 I-40 Frontage Rd, Amarillo TX",
            blurb   => qq|If you see nothing else on Route 66, see this. Bring spray paint. You're allowed to paint the cars.
There is a small linoleum mosaic embedded into the asphalt near the entrance.|,
        },
        {
            name    => "Milburn-Price Culture Museum",
            address => "1005 Coke St, Vega TX",
            blurb   => qq|The best places defy description. The first time I visited, I made a recording of my ten-step philosophy of life via a telephone booth. The second time I visited, I held a tarantula in my hands. The third time I visited, I mentioned that my pocket knife had been stolen, and the owner gifted me one from his huge stash. What is it you're actually supposed to be doing here? I still haven't figured that out.|,
        },
        {
            name    => "Mama Jo's Pies",
            address => "922 E Main St, Vega TX",
            blurb   => qq|They have cherry pies here.|,
        },
        {
            name    => "Midpoint Cafe",
            address => "305 Historic Rte 66, Adrian TX",
            blurb   => qq|You're at the midpoint of Route 66. The two most crucial points in a story are the midpoint (halfway through the story) and the all-is-lost moment (two-thirds of the way through the story). The midpoint and the all-is-lost moment tend to mirror each other. Things seem good now. But the story isn't over. Things are about to take a turn.|,
        },
        {
            name    => "Dream Maker Station",
            address => "307 US Rte 66, Adrian TX",
            blurb   => qq||,
        },
        {
            name    => "Glenrio TX Ghost Town",
            address => "I-40BL, Hereford TX",
            blurb   => qq|See what I mean about the story taking a turn?|,
        },
        {
            name    => "Russell's Travel Center",
            address => "1583 Frontage Rd 4132, Glenrio NM",
            blurb   => qq|It looks pretty much like a normal gas station, but go inside, and be delighted.|,
        },
        {
            name    => "World's Largest Flip Flop",
            address => "602 Rte 66, San Jon NM",
            blurb   => qq|A dream is something real that exists only in the mind of a lazy person. The World's Largest Flip Flop was once just a dream. Now it is real.|,
        },
        {
            name    => "Palomino Motel",
            address => "1215 E Rte 66 Blvd, Tucumcari NM",
            blurb   => qq|Tucumcari is the closest you will come to experiencing Route 66 as it was in the old days. It's not just a neon revival town. Some of those old signs are still buzzing, unrestored.|,
        },
        {
            name    => "Watson's BBQ",
            address => "502 S Lake St, Tucumcari NM",
            blurb   => qq|I don't know if this place is still open, but it's pretty fun to look at from the outside, too.|,
        },
        {
            name    => "Del's Restaurant",
            address => "1202 US Rte 66, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "Roadrunner Lodge Motel",
            address => "1023 E Rte 66 Blvd, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "TeePee Curios",
            address => "924 E Rte 66 Blvd, Tucumcari NM",
            blurb   => qq|I really do buy very few antiques and souvenirs. If I buy something, the place must be really good. I bought a beautiful vintage New Mexico road runner license plate here.|,
        },
        {
            name    => "Blue Swallow Motel",
            address => "815 E Rte 66 Blvd, Tucumcari NM",
            blurb   => qq|Does Tucumcari need and deserve a mass infusion of cash? Yes, but the money should only be used for preservation. Nothing new should be added.|,
        },
        {
            name    => "Motel Safari",
            address => "722 E Rte 66 Blvd, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "Tucumcari Historical Museum",
            address => "416 S Adams St, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "La Cita",
            address => "820 S 1st St, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "Blake's Lotaburger",
            address => "2523 S 1st St, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "Ranch House Cafe",
            address => "1017 W Tucumcari Blvd, Tucumcari NM",
            blurb   => qq||,
        },
        {
            name    => "Tristar Inn Xpress",
            address => "1302 W Rte 66 Blvd, Tucumcari NM",
            blurb   => qq|Room 118 has a secret hidden behind the mirror. Search for "Room Attack" on Wasteland Firebird's YouTube channel if you want to know more.|,
        },
        {
            name    => "Richardson Store",
            address => "Tucumcari, NM",
            blurb   => qq||,
        },
        {
            name    => "Cuervo Ghost Town",
            address => "Cuervo NM",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Auto Museum",
            address => "2463 Historic Rte 66, Santa Rosa NM",
            blurb   => qq||,
        },
        {
            name    => "Old Rio Pecos Ranch Truck Terminal",
            address => "2358 US Rte 66, Santa Rosa NM",
            blurb   => qq||,
        },
        {
            name    => "Sun & Sand Restaurant",
            address => "2050 US Rte 66, Santa Rosa NM",
            blurb   => qq|Last time I came through, the most beautiful sign on Route 66 was lying on the ground, destroyed by rust, wind, and entropy. Just one year before, I'd seen it standing, proud and tall. It's ok to cry. Not just for the sign. For all of Route 66. For everyone who's come and gone. For the American Dream that's been all but forgotten.|,
        },
        {
            name    => "Bowlin's Flying C Ranch",
            address => "Exit 234, I-40, Encino NM",
            blurb   => qq||,
        },
        {
            name    => "Clines Corners Travel Center",
            address => "Clines Corners NM",
            blurb   => qq|This successful business has cheap apartments on-site and good paying jobs. It would be a great place for a young person to get started building their own American Dream. It's a bit desolate, but no one said it would be easy. If you know a young person who's "failed to launch," (still living with their parents in their twenties or thirties) offer to buy them a bus ticket to Clines Corners.|,
        },
        {
            name    => "Sal & Inez's Service Station",
            address => "421 US Rte 66, Moriarty NM",
            blurb   => qq||,
        },
        {
            name    => "Country Friends Antiques",
            address => "1005 Old US Rte 66, Moriarty NM",
            blurb   => qq|This place features a rare sputnik-style Roto-Sphere sign on top of the building.|,
        },
        {
            name    => "Tinkertown Museum",
            address => "121 Sandia Crest Rd, Sandia Park NM",
            blurb   => qq|One man built this place while the rest of us were watching television.|,
        },
        {
            name    => "Bow & Arrow Lodge",
            address => "8300 Central Ave SE, Albuquerque NM",
            blurb   => qq|The works of Vince Gilligan, set in Albuquerque, ranked: 1. Pluribus (the most important battle humanity has ever fought, but you might have trouble deciding which side you're on). 2. Better Call Saul (watch it before Breaking Bad, it's better, and it's a prequel anyway). 3. Breaking Bad.|,
        },
        {
            name    => "Loma Verde Motel sign",
            address => "7503 Central Ave NE, Albuquerque NM",
            blurb   => qq|I'm not here to show you a good time. I'm here to show you America, for better or for worse. Some towns on Route 66 are now worse than ghost towns. They are zombie towns.|,
        },
        {
            name    => "Hotel Zazz",
            address => "3711 Central Ave NE, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "M'tucci's Bar Roma",
            address => "3222 Central Ave SE, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "Frontier Restaurant",
            address => "2400 Central Ave SE, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "66 Diner",
            address => "1405 Central Ave NE, Albuquerque NM",
            blurb   => qq|Sometimes they have cherry pie.|,
        },
        {
            name    => "The Imperial",
            address => "701 Central Ave NE, Albuquerque NM",
            blurb   => qq|This is the place to stay when in Albuquerque.|,
        },
        {
            name    => "Kimo Theatre",
            address => "423 Central Ave NW, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "Dog House Drive In",
            address => "1216 Central Ave NW, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "El Vado Motel",
            address => "2500 Central Ave SW, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "Golden Pride",
            address => "5231 Central Ave NW, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "Western View Steak Diner & House",
            address => "6411 Central Ave NW, Albuquerque NM",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Visitor Center",
            address => "12300 Central Ave SW, Albuquerque NM",
            blurb   => qq|This site is still under development, but now you can go in. It's getting good. There's a neon sign park out front.|,
        },
        {
            name    => "Budville Trading Post",
            address => "HC 77 Box 1A, Seama NM",
            blurb   => qq|There is a small linoleum mosaic embedded into the asphalt.|,
        },
        {
            name    => "Villa de Cubero Trading Post",
            address => "1406 NM 124, Casa Blanca NM",
            blurb   => qq||,
        },
        {
            name    => "Ruins of Whiting Brothers Gas Station",
            address => "San Fidel NM",
            blurb   => qq|There is a small linoleum mosaic embedded into the asphalt.|,
        },
        {
            name    => "West Theatre",
            address => "118 W Santa Fe Ave, Grants NM",
            blurb   => qq||,
        },
        {
            name    => "New Mexico Mining Museum",
            address => "100 Iron Ave, Grants NM",
            blurb   => qq|Go down the elevator.|,
        },
        {
            name    => "Old Bluewater Motel",
            address => "2331 NM-122, Bluewater NM",
            blurb   => qq||,
        },
        {
            name    => "Bowlin's Bluewater Outpost",
            address => "136 Main St, Bluewater NM",
            blurb   => qq||,
        },
        {
            name    => "Indian Village Gift Shop",
            address => "101 US Rte 66, Continental Divide NM",
            blurb   => qq||,
        },
        {
            name    => "Fort Wingate Army Depot",
            address => "506 US Rte 66, Church Rock NM",
            blurb   => qq||,
        },
        {
            name    => "Earl's Family Restaurant",
            address => "1400 E Hwy 66, Gallup NM",
            blurb   => qq|Probably not what you're expecting.|,
        },
        {
            name    => "Blue Spruce Lodge",
            address => "1119 E Hwy 66, Gallup NM",
            blurb   => qq||,
        },
        {
            name    => "Historic El Rancho Hotel",
            address => "1000 E Hwy 66, Gallup NM",
            blurb   => qq||,
        },
        {
            name    => "John's Used Cars",
            address => "416 W Coal Ave, Gallup NM",
            blurb   => qq|There's a used car salesman Muffler Man here.|,
        },
        {
            name    => "Yellowhorse Trading Post",
            address => "I-40 Exit 359, Lupton AZ",
            blurb   => qq|I prefer using the Canadian term "First Nations" instead of saying "Indian" (they're not from India) or "Native American" (anyone born in America is native to America). But I'm happy to refer to someone in any way that they ask me to.|,
        },
        {
            name    => "Fort Courage",
            address => "Houck AZ",
            blurb   =>
              qq|The Pancake House that used to be here was destroyed in 2026. Last time I visited, the fort building inspired by the TV show F-Troop was still here, but who knows what you'll find by the time you read this. We've reached the all-is-lost moment in our story. We're two-thirds of the way through. It's the mirror of the midpoint, back when things still seemed so good. Things don't seem so good, now. We're about to break into Act III, the climax. Let's hope things get better.|,
        },
        {
            name    => "Dotch Windsor's Painted Desert Trading Post",
            address => "Chambers AZ",
            blurb   =>
qq|Take exit 320, head east a bit, then take the dirt road north half a mile. Stop at the gate that has a tiny sign that says Painted Desert Trading Post. There is a lock with a code on it. You can call the number on the sign to get the code, you will need to text them a photo of your id. Enter the code into the lock and hit the unlock button. Go through the gate and close it behind you. Immediately turn left, go west 2.6 miles. When you get to the Trading Post, you can go in, but make sure to keep all gates closed when you leave.
|,
        },
        {
            name    => "Petrified Forest National Park",
            address => "Petrified Forest AZ",
            blurb   => qq|The "forest" is actually a bunch of fallen, crystalized logs. You have to get out and look at them up close to understand.|,
        },
        {
            name    => "Stewart's Petrified Wood Shop",
            address => "Washboard Rd, Holbrook AZ",
            blurb   => qq||,
        },
        {
            name    => "Knife City Outlet",
            address => "7699 Sun Valley Rd, Sun Valley AZ",
            blurb   => qq|Last time I visited this place, the flamethrowers were gone. But you can still ask them to show you several types of weapons that are illegal in Chicago and Los Angeles. And most other Western countries.|,
        },
        {
            name    => "El Rancho Restaurant & Motel",
            address => "867 Navajo Blvd, Holbrook AZ",
            blurb   => qq||,
        },
        {
            name    => "Wigwam Motel",
            address => "811 W Hopi Dr, Holbrook AZ",
            blurb   => qq|You gotta reserve these funky hotels early. I've never found one with a vacancy upon arrival.|,
        },
        {
            name    => "Geronimo Trading Post",
            address => "5372 Geronimo Rd, Joseph City AZ",
            blurb   => qq||,
        },
        {
            name    => "Here It Is Jack Rabbit Trading Post",
            address => "3386 US Rte 66, Joseph City AZ",
            blurb   => qq|The most iconic old shop on the entire Route.|,
        },
        {
            name    => "Falcon Restaurant & Lounge",
            address => "1113 E 3rd St, Winslow AZ",
            blurb   => qq||,
        },
        {
            name    => "Earl's Route 66 Motor Court",
            address => "512 E 3rd St, Winslow AZ",
            blurb   => qq||,
        },
        {
            name    => "La Posada Hotel",
            address => "303 E 2nd St, Winslow AZ",
            blurb   => qq|My absolute favorite hotel on Route 66. Quirky, old, and luxurious. Unlike big city hotels, you can park you own car. You don't need a porter to take your bags to your room. And you can open the gosh-danged windows.|,
        },
        {
            name    => "Route 66 Delta Motel",
            address => "2141 W 3rd St, Winslow AZ",
            blurb   => qq||,
        },
        {
            name    => "Meteor City Trading Post",
            address => "40440 Interstate 40 WB, Winslow AZ",
            blurb   => qq|This place was recently reopened and it's a lot of fun. I rented a four-person bike. I pedaled as fast as I could through the park, completing the journey in under a minute and terrifying my companions.|,
        },
        {
            name    => "Meteor Crater",
            address => "Meteor Crater Rd AZ",
            blurb   => qq||,
        },
        {
            name    => "Two Guns",
            address => "AZ",
            blurb   => qq|The first time I visited this place, it was for a group photo shoot. I ended up taking sexy photos of a woman who later went on to indirectly cause a noteworthy shooting death on a movie set. No one has ever seen these photos. If any tabloid is interested in making me rich, get in touch. If you think you saw these photos in my YouTube video, oh no, you didn't. You saw the ones that were safe for YouTube.|,
        },
        {
            name    => "Twin Arrows Trading Post Ruins",
            address => "East of Flagstaff AZ",
            blurb   => qq|There's only one arrow here now. Someone should make a perfect replica and surreptitiously install it in the middle of the night. Or just put the original one back. The rumor is, it's still out there somewhere.|,
        },
        {
            name    => "Walnut Canyon Bridge",
            address => "Townsend-Winona Rd, Winona AZ",
            blurb   => qq||,
        },
        {
            name    => "Americana Motor Hotel",
            address => "2650 E Rte 66, Flagstaff AZ",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Dog Haus",
            address => "1302 E Rte 66, Flagstaff AZ",
            blurb   => qq||,
        },
        {
            name    => "Flagstaff Visitor Center",
            address => "1 E Rte 66, Flagstaff AZ",
            blurb   => qq||,
        },
        {
            name    => "Weatherford Hotel",
            address => "23 N Leroux St, Flagstaff AZ",
            blurb   => qq||,
        },
        {
            name    => "J Lawrence Walkup Skydome",
            address => "1705 S San Francisco St, Flagstaff AZ",
            blurb   => qq|There are two Muffler Men here, one on each side.|,
        },
        {
            name    => "Galaxy Diner",
            address => "931 W Rte 66, Flagstaff AZ",
            blurb   => qq||,
        },
        {
            name    => "Pine Breeze Inn",
            address => "10520 W Rte 66, Flagstaff AZ",
            blurb   => qq||,
        },
        {
            name    => "Old Route 66 Parks Store",
            address => "12963 Old Rte 66 Ste 50340, Parks AZ",
            blurb   => qq||,
        },
        {
            name    => "Bearizona Wildlife Park",
            address => "1500 E Rte 66, Williams AZ",
            blurb   => qq|I hate most zoos. They're like prisons for animals that didn't do anything wrong. But this one is nice. And they trust you enough to let you drive right through it, just like in the old days.|,
        },
        {
            name    => "Rod's Steak House",
            address => "301 E Historic Rte 66, Williams AZ",
            blurb   => qq|Williams is a neon revival town. Try to get a look at its signs at night.|,
        },
        {
            name    => "Pete's Route 66 Gas Station Museum",
            address => "101 E Rte 66, Williams AZ",
            blurb   => qq||,
        },
        {
            name    => "Historic Grand Canyon Hotel",
            address => "145 Historic Rte 66, Williams AZ",
            blurb   => qq||,
        },
        {
            name    => "Williams Visitor Center",
            address => "200 W Railroad Ave, Williams AZ",
            blurb   => qq||,
        },
        {
            name    => "Cruiser's Route 66 Cafe",
            address => "233 W Rte 66, Williams AZ",
            blurb   => qq||,
        },
        {
            name    => "Arizona 9 Motor Hotel",
            address => "315 W Rte 66, Williams AZ",
            blurb   => qq||,
        },
        {
            name    => "Ash Fork Route 66 Museum",
            address => "901 Old Rte 66, Ash Fork AZ",
            blurb   => qq|They might have the old Hi-Line Motel sign here.|,
        },
        {
            name    => "Aztec Motel & Creative Space",
            address => "22200 Historic Rte 66, Seligman AZ",
            blurb   => qq||,
        },
        {
            name    => "Delgadillo's Snow Cap",
            address => "301 AZ-66, Seligman AZ",
            blurb   => qq|Angel Delgadillo has lived in Seligman for his entire life. He's one year younger than the Route. He saved Route 66 in 1987 by founding the Historic Route 66 Association of Arizona.|,
        },
        {
            name    => "Route 66 Road Relics",
            address => "22255 W Old Highway 66, Seligman AZ",
            blurb   => qq||,
        },
        {
            name    => "Delgadillo's Gift Shop",
            address => "22265 Historic Rte 66, Seligman AZ",
            blurb   => qq||,
        },
        {
            name    => "Rusty Bolt",
            address => "22345 W Old Highway 66, Seligman AZ",
            blurb   => qq|I sometimes leave copies of my books on the used book shelf here. They sell for 50¢ each.|,
        },
        {
            name    => "Supai Motel",
            address => "22450 AZ-66, Seligman AZ",
            blurb   => qq|Room 3 has a hidden secret. It's not behind the mirror. Good luck finding it. If you need help, search for "Room Attack" on Wasteland Firebird's YouTube channel.|,
        },
        {
            name    => "Roadkill Cafe",
            address => "22830 W AZ-66, Seligman AZ",
            blurb   => qq||,
        },
        {
            name    => "Westside Lilo's Cafe",
            address => "22855 AZ-66, Seligman AZ",
            blurb   => qq||,
        },
        {
            name    => "Frontier Motel Cafe",
            address => "16118 Historic Rte 66, Valentine AZ",
            blurb   => qq|The best hand-painted sign on Route 66 is the dude with the long arms.|,
        },
        {
            name    => "Old 76 Station",
            address => "12526 Historic Rte 66, Valentine AZ",
            blurb   => qq||,
        },
        {
            name    => "Hackberry General Store",
            address => "11255 AZ-66, Kingman AZ",
            blurb   => qq|Pet the cat's tummy.|,
        },
        {
            name    => "Arcadia Lodge sign",
            address => "909 E Andy Devine Ave, Kingman AZ",
            blurb   => qq||,
        },
        {
            name    => "TNT Auto Center",
            address => "535 E Andy Devine Ave, Kingman AZ",
            blurb   => qq|There is a Bob Waldmire mural here.|,
        },
        {
            name    => "Kingman Railroad Museum",
            address => "402 E Andy Devine Ave, Kingman AZ",
            blurb   => qq||,
        },
        {
            name    => "Sirens Cafe",
            address => "419 Beale St, Kingman AZ",
            blurb   => qq|There is a small linoleum mosaic embedded into the crosswalk here.|,
        },
        {
            name    => "Hotel Beale sign",
            address => "331 E Andy Devine Ave, Kingman AZ",
            blurb   => qq|The sign lights up again, after decades of darkness.|,
        },
        {
            name    => "Tin Can Alley",
            address => "211 E Andy Devine Ave, Kingman AZ",
            blurb   => qq|Downtown glamping.|,
        },
        {
            name    => "Mr. D'z Route 66 Diner",
            address => "105 E Andy Devine Ave, Kingman AZ",
            blurb   => qq|The 70s electric Citicars are an odd choice, but if they'd been 57 Chevys, they'd just blend into the background.|,
        },
        {
            name    => "Cool Springs Station",
            address => "8275 Oatman Rd, Golden Valley AZ",
            blurb   => qq|Large vehicles and vehicles with large trailers, beware the upcoming curvy road known as the Sidewinder. But try not to miss Oatman.|,
        },
        {
            name    => "Oatman",
            address => "Oatman AZ",
            blurb   => qq|The first time I drove through this town, I had no idea what it was or why it was here. Somehow, for some reason, I had been teleported back in time to The Old West.|,
        },
        {
            name    => "Claypool & Co building",
            address => "719 W Broadway St, Needles CA",
            blurb   => qq||,
        },
        {
            name    => "Wagon Wheel Restaurant",
            address => "2420 Needles Hwy, Needles CA",
            blurb   => qq||,
        },
        {
            name    => "Rio Del Sol Inn",
            address => "1111 Pashard St, Needles CA",
            blurb   => qq||,
        },
        {
            name    => "Goffs Schoolhouse",
            address => "37198 Lanfair Rd, Essex CA",
            blurb   => qq||,
        },
        {
            name    => "Guardian Lion East",
            address => "National Trails Hwy, Amboy CA",
            blurb   => qq|Anyone can spray paint a bridge overpass. Only a true genius can hand-carve two multi-ton lions out of marble, transport and install them with no one noticing, leave people confused, and make one of them disappear for the entire year of 2019 for some reason.|,
        },
        {
            name    => "Road Runner's Retreat sign",
            address => "Chambless CA",
            blurb   =>
qq|This one is out of order for a reason. If you've navigated the road closures and construction detours and made it to Guardian Lion East, you can probably find the Road Runner's Retreat sign. Head back the way you came, five miles east on 66. Do not make the left onto Kelbaker Rd. Instead, drive around the road closed signs. The road is in great condition all the way to the Retreat sign. Those road closed signs should really be moved back a couple miles. Beyond the Retreat sign, road conditions are anyone's guess. Recently restored, this sign even lights up sometimes in the evenings.|,
        },
        {
            name    => "Guardian Lion West",
            address => "National Trails Hwy, Amboy CA",
            blurb   => qq||,
        },
        {
            name    => "Roy's Motel & Cafe",
            address => "87520 National Trails Hwy, Amboy CA",
            blurb   => qq|The most iconic operating gas station on Route 66. They made a cake for The Great Route 66 Centennial Convergence. It had a picture of my face on it. They clearly recognize my eminence and genius.|,
        },
        {
            name    => "Former Whiting Brothers Gas Station",
            address => "68517 County Rd 66, Ludlow CA",
            blurb   => qq|People used to live and work in these buildings. They lived their entire lives here.|,
        },
        {
            name    => "Ludlow Cafe",
            address => "68315 National Trails Hwy, Ludlow CA",
            blurb   => qq|I've never made it to this place during business hours, but I'm gonna keep trying.|,
        },
        {
            name    => "Whiting Brothers Service and Tony's Spaghetti Building",
            address => "46756 National Trails Hwy, Newberry Springs CA",
            blurb   => qq|Attachment leads to suffering.|,
        },
        {
            name    => "Bagdad Cafe",
            address => "46548 National Trails Hwy, Newberry Springs CA",
            blurb   => qq|This place is beloved by weird German tourists because of the 1987 film Bagdad Cafe. That film is about weird German tourists finding their home-away-from-home at this place. Owner Andrea Pruett slept on a mattress on the floor here while rain dripped through the leaky roof. She did this to keep the place alive for you and me. She's no longer with us. Leave a tip in the jar.|,
        },
        {
            name    => "Sand-Swallowed Abandoned Homes",
            address => "Newberry Rd & Palma Vista Rd, Newberry Springs CA",
            blurb   => qq|I haven't found these buildings yet, but they tell me you can find them just beyond this intersection. Don't drive in sand of any depth.|,
        },
        {
            name    => "The Barn",
            address => "44560 National Trails Hwy, Newberry Springs CA",
            blurb   => qq|Like Roy's Cafe, The Barn always treats me like the celebrity that I am. I'm sure they'll be nice to you peons, too.|,
        },
        {
            name    => "The Russian House",
            address => "35421 County Rd 66, Daggett CA",
            blurb   => qq||,
        },
        {
            name    => "Desert Market",
            address => "35596 Santa Fe St, Daggett CA",
            blurb   => qq||,
        },
        {
            name    => "Daggett Garage",
            address => "35565 Santa Fe St, Daggett CA",
            blurb   => qq||,
        },
        {
            name    => "Daggett Historical Museum",
            address => "33703 2nd St, Daggett CA",
            blurb   => qq||,
        },
        {
            name    => "Penny's Diner",
            address => "35450 Yermo Rd, Yermo CA",
            blurb   => qq||,
        },
        {
            name    => "Peggy Sue's 50's Diner",
            address => "35654 Yermo Rd, Yermo CA",
            blurb   => qq||,
        },
        {
            name    => "Liberty Sculpture Park",
            address => "37570 Yermo Rd, Yermo CA",
            blurb   => qq|Communism simply doesn't work. Capitalism creates inequality, but overall, it works best for everyone. World GDP sat still for all of human history. Then capitalism came along and made that graph look like a hockey stick.|,
        },
        {
            name    => "EddieWorld",
            address => "36017 Calico Rd, Yermo CA",
            blurb   => qq||,
        },
        {
            name    => "Thrift & More",
            address => "457 W Yermo Rd, Yermo CA",
            blurb   => qq||,
        },
        {
            name    => "Original Del Taco Location",
            address => "38434 E Yermo Rd, Yermo CA",
            blurb   => qq||,
        },
        {
            name    => "Calico Ghost Town",
            address => "Calico CA",
            blurb   => qq||,
        },
        {
            name    => "Skyline Drive-In Theater",
            address => "31175 Old Hwy 58, Barstow CA",
            blurb   => qq||,
        },
        {
            name    => "Barstow Train McDonald's",
            address => "1611 E Main St, Barstow CA",
            blurb   => qq|It's just a McDonalds, but the dining rooms are made of real train cars.|,
        },
        {
            name    => "Mojave River Valley Museum",
            address => "270 E Virginia Way, Barstow CA",
            blurb   => qq||,
        },
        {
            name    => "Route 66 Motel",
            address => "195 Main St, Barstow CA",
            blurb   => qq||,
        },
        {
            name    => "Harvey House",
            address => "685 N 1st Ave, Barstow CA",
            blurb   => qq|There is a tiny linoleum mosaic embedded in the asphalt on the road out in front of this place.|,
        },
        {
            name    => "Elmer's Bottle Tree Ranch",
            address => "24266 National Trails Hwy, Oro Grande CA",
            blurb   => qq||,
        },
        {
            name    => "Emma Jean's Holland Burger Cafe",
            address => "17143 N D St, Victorville CA",
            blurb   => qq||,
        },
        {
            name    => "California Route 66 Museum",
            address => "16825 D St, Victorville CA",
            blurb   => qq||,
        },
        {
            name    => "Santa Fe Trading Company",
            address => "15464 7th St, Victorville CA",
            blurb   => qq|This has been a family-owned business since forever. It used to be a gas station, then it was a candy store, now it's something else entirely. They make their own pomegranate jelly, if that helps.|,
        },
        {
            name    => "First Original McDonald's Museum",
            address => "1398 N E St, San Bernardino CA",
            blurb   => qq||,
        },
        {
            name    => "Mitla Cafe",
            address => "602 N Mt Vernon Ave, San Bernardino CA",
            blurb   => qq||,
        },
        {
            name    => "Wigwam Village Motel",
            address => "2728 Foothill Blvd, San Bernardino CA",
            blurb   => qq||,
        },
        {
            name    => "Cucamonga Service Station",
            address => "9670 Foothill Blvd, Rancho Cucamonga CA",
            blurb   => qq|There might be a custom brick here from The Great Route 66 Centennial Convergence.|,
        },
        {
            name    => "The Sycamore Inn",
            address => "8318 Foothill Blvd, Rancho Cucamonga CA",
            blurb   => qq||,
        },
        {
            name    => "Magic Lamp Inn Restaurant",
            address => "8189 Foothill Blvd, Rancho Cucamonga CA",
            blurb   => qq|This place has a strict dress code and no mobile phones are allowed. I hope my leather jacket covered in paint marker art summarizing my entire philosophy of life in ten simple principles is ok.|,
        },
        {
            name    => "The Donut Man",
            address => "915 E Rte 66, Glendora CA",
            blurb   => qq|My philosophy of life, principle #1:
I AM CONSCIOUS.
I know this for sure.|,
        },
        {
            name    => "Windmill Denny's",
            address => "7 E Huntington Dr, Arcadia CA",
            blurb   => qq|Principle #2:
HAPPINESS IS GOOD.
I know this for sure, too.|,
        },
        {
            name    => "Saga Motor Hotel",
            address => "1633 E Colorado Blvd, Pasadena CA",
            blurb   => qq|Principle #3:
I CAN USUALLY TRUST MY SENSES.
I have to either believe this, or choose not to function.|,
        },
        {
            name    => "Shakers",
            address => "601 Fair Oaks Ave, South Pasadena CA",
            blurb   => qq|Principle #4:
THE LAWS OF NATURE ARE CONSISTENT.
I have to either believe this, or choose not to function.|,
        },
        {
            name    => "Fair Oaks Pharmacy & Soda Fountain",
            address => "1526 Mission St, South Pasadena CA",
            blurb   => qq|Principle #5:
THE LAWS OF HUMAN NATURE ARE CONSISTENT.
This implies that we can figure out some rules of ethics, virtue, and morality.|,
        },
        {
            name    => "Galco's Old World Grocery",
            address => "5702 York Blvd, Los Angeles CA",
            blurb   => qq|Principle #6:
REASON IS HOW WE ACQUIRE KNOWLEDGE.
Deductive logic, like math, and inductive reasoning, like science, are how we understand the universe and how we understand ourselves.|,
        },
        {
            name    => "Highland Park Bowl",
            address => "5621 N Figueroa St, Los Angeles CA",
            blurb   => qq|Principle #7:
FREEDOM IS HOW WE ACHIEVE HAPPINESS.
Most people agree that freedom makes them happy.|,
        },
        {
            name    => "La Fuente Restaurant",
            address => "5552 N Figueroa St, Los Angeles CA",
            blurb   => qq|Principle #8:
ECONOMIC FREEDOM IS HOW WE ACHIEVE PROSPERITY.
Capitalism works. I define capitalism as "economic freedom," not "cronyist plutocracy." I assure you, I hate cronyist plutocracy as much as anyone. Capitalism doesn't exist to hold poor people down. It exists to let brilliant people do brilliant things.|,
        },
        {
            name    => "Cielito Lindo",
            address => "E-23 Olvera St, Los Angeles CA",
            blurb   => qq|Principle #9:
FREEDOM IS A POSITIVE-SUM GAME.
If two people agree to participate in some type of financial or emotional transaction, they do it because they both feel like it will benefit them. It's not that one of them is right, and one of them is wrong. They are both right. They both benefit. Therefore, every transaction makes the world a slightly better place.|,
        },
        {
            name    => "Million Dollar Theater",
            address => "307 S Broadway, Los Angeles CA",
            blurb   => qq|Principle #10:
CREATE VALUE.
It took me years to figure out a way to summarize my entire philosophy in a way that it would fit on a bumper sticker. If you gain nothing else from my existence in this universe, please take these two words with you and keep them handy in your mind. Steal these words, copy these words, say these words. Create value.|,
        },
        {
            name    => "Clifton's building",
            address => "648 S Broadway, Los Angeles CA",
            blurb   => qq|This spot is described as the "real" end of Route 66. But for a climax to our Route 66 story, I think we can do better. Keep going, it's about to get good.|,
        },
        {
            name    => "The Orpheum Theatre",
            address => "842 S Broadway, Los Angeles CA",
            blurb   => qq||,
        },
        {
            name    => "The United Theater on Broadway",
            address => "929 S Broadway, Los Angeles CA",
            blurb   => qq||,
        },
        {
            name    => "Petersen Automotive Museum",
            address => "6060 Wilshire Blvd, Los Angeles CA",
            blurb   => qq|The best car museum on Earth.|,
        },
        {
            name    => "Tesla Diner",
            address => "7001 Santa Monica Blvd, Los Angeles CA",
            blurb   => qq|Retrofuturistic like nothing you've ever seen.|,
        },
        {
            name    => "The Formosa",
            address => "7156 Santa Monica Blvd, West Hollywood CA",
            blurb   => qq||,
        },
        {
            name    => "Irv's Burgers",
            address => "7998 Santa Monica Blvd, West Hollywood CA",
            blurb   => qq||,
        },
        {
            name    => "Barney's Beanery",
            address => "8447 Santa Monica Blvd, West Hollywood CA",
            blurb   => qq||,
        },
        {
            name    => "Tail O' the Pup",
            address => "8512 Santa Monica Blvd, West Hollywood CA",
            blurb   => qq|I discovered this place when I was watching old episodes of The Rockford Files. They stopped here in the first episode. I had to know if it still existed. That led me to Alison Martino's social media community Vintage Los Angeles. She did a report on the place, as it was being restored and moved. I visited it here, in its new location, as soon as it opened. Pay attention, because there is a secret door nearby.|,
        },
        {
            name    => "NORMS Restaurant",
            address => "470 N La Cienega Blvd, West Hollywood CA",
            blurb   => qq|This is the oldest NORMS diner.|,
        },
        {
            name    => "Edelweiss Chocolates",
            address => "444 N Canon Dr, Beverly Hills CA",
            blurb   => qq|Vintage Los Angeles led me here, too.|,
        },
        {
            name    => "Mel's Drive-In",
            address => "1670 Lincoln Blvd, Santa Monica CA",
            blurb   => qq|The last great diner on Route 66.|,
        },
        {
            name    => "Cal Mar Hotel Suites",
            address => "220 California Ave, Santa Monica CA",
            blurb   => qq|I have stayed in this midcentury masterpiece at least a dozen times. I highly recommend it.|,
        },
        {
            name    => "Santa Monica Pier",
            address => "Santa Monica CA",
            blurb   => qq|There is a small linoleum mosaic embedded in the asphalt at the crosswalk. The 66-To-Cali shack is the end of your journey.|,
        },
    ];
    my $work_dir = './data';
    my $qr_dir   = File::Spec->catfile( $work_dir, 'qr_codes/' );
    my $out_docx = File::Spec->catfile( $work_dir, 'wasteland_firebirds_big_list-base.docx' );
    my $out_html = File::Spec->catfile( $work_dir, 'index.html' );
    my $qr_width = '4.0in';
    my $qrs      = [];
    my $links    = [];
    set_up_qr_dir($qr_dir);
    ensure_dir($work_dir);
    generate_qr_codes_and_links( $addresses, $qr_dir, $qrs, $links );
    make_doc( $addresses, $qrs, $links, $work_dir, $qr_dir, $qr_width, $out_docx, $out_html, $line_break, $page_break );
    print "Open DOCX in Pages.\n";
    print "Manually choose a new font for all of the place names and addresses.\n";
    print "Click Document, Document, Footer to add a footer.\n";
    print "Click Document, Section, uncheck Left and Right are Different.\n";
    print "Click Document, Section, uncheck Match Previous Section.\n";
    print "In the document itself, click where you want to insert a section break (where you want page numbering to start/restart), then click Insert, Section Break.\n";
    print "Go to the footer and click it and Insert Page Number, ignoring the wrong start number.\n";
    print "Click Document, Section, Page Number, Start At.\n";
    print "Add new sections for every state. Update the footer with the state name. You should only need to update it once for the entire section. Make page numbering continue from previous section.";
    print "At Midpoint, add a new section break and restart page numbering as above, fixing the start number. Afterward, go back to using Continue From Previous Section.\n";
    print "Under Format, Body, Style, Font, choose Garamond. There is a gear icon also, bring character spacing in by 1%.";
    print "Fix justification to be both left and right.\n";
    print "Add photos to the beginning, midpoint, and end.\n";
    print "Mess with footers and Sections to get the page numbering to start and stop correctly.\n";
    print "Do any other needed tweaks. Export PDF.\n";
    system( 'open', $out_docx );

    #system( 'open', $out_html );
}

sub ensure_dir {
    my ($d) = @_;
    -d $d or mkdir $d or die "Can't mkdir $d: $!";
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

sub generate_qr_codes_and_links {
    my ( $addresses, $output_dir, $qrs, $links ) = @_;
    my $count         = 0;
    my $past_midpoint = 0;
    for my $address_hashref (@$addresses) {
        my $place_name = $address_hashref->{name};
        my $address    = $address_hashref->{address};
        chomp $address;

        # Google maps results are better when you always give the place name, too
        #if ( $address !~ /^[0-9]/ ) {
        $address = "$place_name, $address";

        #}
        $count++;

        # Create the Google Maps URL
        my $query    = uri_escape_utf8($address);
        my $maps_url = "https://www.google.com/maps/search/?api=1&query=$query";

        # Generate the QR codes, Ecc => 1 is Error Correction Level L (Low), ModuleSize controls the pixel size of the blocks
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

            # Sometimes the locations start on the right side, sometimes the left. And,
            # getting past the midpoint of the book, we want to switch the alternation.
            # That's because we add an extra unnumbered bonus midpoint page with a photo.
            my $LEFT_SIDE        = 0;
            my $RIGHT_SIDE       = 1;
            my $side_to_start_on = $RIGHT_SIDE;    # adjust as needed
            if (                                   #
                ( ( $count % 2 == $side_to_start_on ) && ( !$past_midpoint ) )
                ||                                 #
                ( ( $count % 2 == !$side_to_start_on ) && ($past_midpoint) )
              )
            {
                $pad = $w;
            }
            if ( $place_name eq 'Midpoint Cafe and Gift Shop' ) {
                $past_midpoint = 1;
            }

            my $canvas = GD::Image->new( $w + $w, $h );
            my $white  = $canvas->colorAllocate( 255, 255, 255 );
            my $black  = $canvas->colorAllocate( 0,   0,   0 );
            $canvas->filledRectangle( 0, 0, $w + $w, $h, $white );
            if ( $place_name eq "Dotch Windsor's Painted Desert Trading Post" ) {
                $canvas->filledRectangle( $pad, 0, 0, $w, $h, $black );
            }
            else {
                $canvas->copy( $qr, $pad, 0, 0, 0, $w, $h );
            }
            $canvas->rectangle( 0, 0, $w + $w - 1, $h - 1, $black );

            # Label in blank area
            my $text = "STAMP / STICKER / SIGNATURE";
            my $font = gdTinyFont;
            my $text_x;
            if ( $pad == 0 ) {

                # QR on left, blank area on right
                $text_x = $w + 5;
            }
            else {
                # QR on right, blank area on left
                $text_x = 5;
            }
            my $text_y = 5;
            $canvas->string( $font, $text_x, $text_y, $text, $black );

            # Draw a little arrow
            my $arrow_x = $text_x + ( length($text) * 5 ) + 3;
            my $arrow_y = $text_y + 1;

            # shaft
            $canvas->line( $arrow_x + 2, $arrow_y, $arrow_x + 2, $arrow_y + 4, $black );

            # arrowhead
            $canvas->line( $arrow_x,     $arrow_y + 3, $arrow_x + 2, $arrow_y + 5, $black );
            $canvas->line( $arrow_x + 4, $arrow_y + 3, $arrow_x + 2, $arrow_y + 5, $black );

            print $img_fh $canvas->png();
            close $img_fh;
            push( @$qrs,   $filename );
            push( @$links, $maps_url );
        }
        else {
            die "[$count] Error generating QR code for: $address\n";
        }
    }
    return $qrs;
}

sub make_doc {
    my ( $addresses, $qrs, $links, $work_dir, $qr_dir, $qr_width, $out_docx, $out_html, $line_break, $page_break ) = @_;

    # Build a Pandoc md file and an html file for the website
    my $md_path = File::Spec->catfile( $work_dir, 'book.md' );
    open my $md,   '>', $md_path  or die "Can't write '$md_path': $!";
    open my $html, '>', $out_html or die "Can't write '$out_html': $!";

    # Website header
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    $year += 1900;
    my @month_abbrevs = qw(Jan Feb Mar April May Jun Jul Aug Sep Oct Nov Dec);
    my $month_abbrev  = $month_abbrevs[$mon];
    $mon += 1;
    for my $unit ( $mon, $mday, $hour, $min, $sec ) { $unit = sprintf( '%02d', $unit ); }
    print $html qq|
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wasteland Firebird's Big List of the Best Things On Route 66</title>
    <link rel="icon" href="/favicon.png">
    <link rel="stylesheet" href="/biglist.css">
</head>
<body>
<h1>Wasteland Firebird's Big List of the Best Things On Route 66</h1>
<h2>A curious guide to Route 66 and the American Dream, last updated $year $month_abbrev $mday</h2>
<img src="/pictures/image001.jpg">
<h3>Purchasable physical copies of this list in book form will be available right here, SOON. The book includes scannable QR codes for each address, and lots of opinionated blurbs.</h3>
<h3><a href="https://www.youtube.com/playlist?list=PLA_KEM2YJkctJhl8hcghFpyMN1igPFB0p">Wasteland Firebird's Route 66 YouTube playlist is here.</a></h3>
<h3><a href="https://www.google.com/maps/d/u/0/edit?mid=1AhAphxJ0eg_DRkiHp21btHCNyuxCCT4&ll=32.242242784459016%2C-106.71410537451172&z=5">Wasteland Firebird's Big Map is here.</a></h3>
<h3>Wasteland Firebird can be contacted at wastelandfirebird at gmail dot com.</h3>
<ol>
|;

    # Title page
    print $md "Wasteland Firebird's Big List${line_break}of the Best Things On Route 66${line_break}by Wasteland Firebird (John Binns)${line_break}2026 Centennial Second Edition${line_break}";
    print $md $page_break;

    # Copyright page
    print $md "Copyright © 2026 John Binns${line_break}All rights reserved${line_break}wastelandfirebird\@gmail.com${line_break}youtube.com/wastelandfirebird${line_break}wastelandfirebird.com${line_break}";
    print $md $page_break;

    # Dedication page
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
I was hoping for another Freedom Train, a Wagon Train Pilgrimage, New York City's Operation Sail, TV shows, special edition coins, special edition cars, fireworks, air shows, car shows, parades, and red-white-and-blue everything. A few of those things are happening, but something has definitely changed in the last fifty years. The reverence is gone.
${line_break}
When I discovered that Route 66 would have its Centennial in the same year as America's Semiquincentennial, I knew that I had to do something to bring that reverence back.
${line_break}
I traveled Route 66 four times. I made a lot of YouTube videos. I took a lot of notes. I set up a free Route 66 tour I called The Great Route 66 Centennial Convergence. I made flyers, t-shirts, and keychains based on my hand-drawn art. I commissioned miniature "Muffler Man" action figures of myself. I promoted the event so much that I was kicked off of Facebook forever for being a "spammer."
${line_break}
And I created the "2026 Centennial Edition" of this book. Like the t-shirts, keychains, and action figures, the first edition was never for sale. It was free for Convergence participants.
${line_break}
The Great Route 66 Centennial Convergence came to an end on April 30, 2026. But people kept asking for copies of the book. So here it is, the 2026 Centennial Second Edition, with plenty of updates. You can now buy this book at wastelandfirebird.com. If people enjoy it, I'll release a new edition every year. Maybe twice a year.
${line_break}
You might still manage to get a copy of this book for free, if you look hard enough. Be sure to check the Route 66 of Chenoa IL Roadside Attraction Tourist Info booth. You never know what cool stuff people might leave there.
${line_break}
Route 66 goes from Chicago to LA. It represents the idea of going West. Americans have always held out hope that things would be better out West. The Europeans got to the Americas in the first place by heading west.
${line_break}
"Washington [DC] is not a place to live in. The rents are high, the food is bad, the dust is disgusting and the morals are deplorable. Go West, young man, go West and grow up with the country." - Horace Greely
${line_break}
"If [Americans] attained Paradise, they would move on if they heard of a better place farther west." - John Murray
${line_break}
If we save Route 66, we save the American Dream. If we save the American Dream, we save America. If we save America, we save the world. Because the American Dream is not just America's dream. It's everyone's dream.
${line_break}
|;
    print $md $page_break;

    # How to use this book
    print $md qq|
How to use this book
${line_break}
You can use this book on its own, or in conjunction with other guides. The locations in this book are in order from east to west, because that's the direction of America's story. Driving west-to-east on Route 66 is like watching a movie backwards. But this book will work just as well backwards as it will forwards.
${line_break}
I don't include any images. I don't include any descriptions. That's intentional. You're not supposed to be looking at this book. You're supposed to be looking around you. You're not supposed to know what you're getting into. You're supposed to be getting into it.
${line_break}
There will be errors in this book. Please email them to wastelandfirebird\@gmail.com. Don't follow your phone's directions into the middle of nowhere. When visited in order, most of these locations will be fairly close to one another. For most of this trip, you should be, at most, a couple of miles away from an interstate highway. The beautiful part is that the places you visit will feel much more remote than that. If you follow the old Route, you'll often forget that the interstate is even there.
${line_break}
This book is a list of addresses and QR codes that represent online directions to each of my favorite places on Route 66. You can enter each address manually into your navigation app. Or, you can scan the QR codes with your phone by pointing your phone's camera at them. If you visit every place in this book, you will approximately follow Route 66 from one end to the other.
${line_break}
If you want to follow Route 66 more exactly, be aware that there never was a single Route 66. There have always been many "alignments" (alternate routes). Nowadays, much of what used to be known as Route 66 consists of closed roads, potholed roads, dirt roads, private roads, military bases, and dead ends. In a few places, you have no choice but to take the interstate.
${line_break}
I'd recommend taking three weeks to do your Route 66 trip. If you want to explore every inch of every route that was ever known as "Route 66," you'd better give yourself several months.
${line_break}
Many businesses along the Route have custom rubber stamps. I've left an empty space beside all of the QR codes for these stamps. You could also use those spaces for notes, signatures, stickers, or just big checkmarks. 
${line_break}
Be aware that some of the "passport" books you'll find on the Route require small businesses to pay thousands of dollars for the privilege of being advertised in them. No one paid to be in this book. This book is nothing more than a list of places and people that I love.
${line_break}
|;
    print $md $page_break;

    my $place_number = 0;    # Use this as zero-based array index for now
    for my $address_hashref (@$addresses) {
        my $place_name = $address_hashref->{name};
        my $address    = $address_hashref->{address};
        my $blurb      = $address_hashref->{blurb};
        my $qr_path    = File::Spec->catfile( $qr_dir, $qrs->[$place_number] );
        if ( !-f $qr_path ) {
            die "Missing QR file for '$place_number': " . Dumper($qrs);
        }
        my $state;
        if ( $address =~ /([A-Z][A-Z])$/ ) {
            $state = $1;
        }
        else {
            die "Invalid address, expected state at the end of '$address'";
        }

        # Website

        print $html qq|
    <li class="$state">
        <div class="place">
            <div class="place-name">
                $place_name
            </div>
            <div class="place-address">
                <a href="$links->[$place_number]" target="_blank" rel="noopener noreferrer">$address</a>
            </div>
        </div>
    </li>
|;

        $place_number++;    # Now that we have incremented this, we can use it below as a human-readable counter starting at one

        # Book

        # Address (as plain paragraph). If you want it to be, say, a big bold title},
        # define a style in reference.docx and use it via a pandoc Lua filter.
        print $md "$place_name\n";
        print $md $line_break;
        print $md "$address\n";

        # Pandoc supports attribute syntax: {width=...}
        print $md "![]($qr_path){width=$qr_width}\n";
        print $md $line_break;
        if ($blurb) {
            print $md "$blurb\n";
            print $md $line_break;
        }

        # Here's where we insert the bonus midpoint page that causes the QR codes to change their alternation pattern above
        if ( $place_name eq 'Midpoint Cafe and Gift Shop' ) {
            print $md $page_break;
            print $md "Midpoint bonus page!\n";
        }

        # Page break
        print $md $page_break;
    }

    # Conclusion
    print $md qq|
Create value. Create value for people who pay you. That's work. Create value for people who don't pay you. That's kindness. Create value for people you like. That's friendship. Create value for people you don't like. That's self-preservation. Most of all, create value for yourself. That's happiness.
${line_break}
|;
    print $md $page_break;

    print $html qq|
</ol>
<img src="/pictures/image-wf.jpg">
</body>
</html>
|;

    close $html or die "Error closing $out_html: $!";
    close $md   or die "Error closing $md_path: $!";

    # Use a DOCX that matches the print on demand template (margins, page size, headers/footers, fonts, etc).
    # Pandoc will use this as a reference.
    my $reference_docx = './data/wasteland_firebirds_big_list-template.docx';
    my @cmd            = ( 'pandoc', $md_path, '-o', $out_docx, '--reference-doc=' . $reference_docx, );
    print "Running:\n  " . join( ' ', map { /\s/ ? qq("$_") : $_ } @cmd ) . "\n";
    system(@cmd) == 0 or die "pandoc failed";
}
main();
