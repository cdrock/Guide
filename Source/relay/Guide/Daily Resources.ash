import "relay/Guide/QuestState.ash"
import "relay/Guide/Support/Checklist.ash"
import "relay/Guide/Support/LocationAvailable.ash"
import "relay/Guide/Sets/Sets import.ash"



string [int] generateHotDogLine(string hotdog, string description, int fullness)
{
    description += " " + fullness + " full.";
    if (availableFullness() < fullness) {
        hotdog = HTMLGenerateSpanOfClass(hotdog , "r_future_option");
        description = HTMLGenerateSpanOfClass(description , "r_future_option");
    }
    return listMake(hotdog, description);
}


void generateDailyResources(Checklist [int] checklists)
{
    ChecklistEntry [int] resource_entries;
        
    SetsGenerateResources(resource_entries);
    QuestsGenerateResources(resource_entries);
    
    if (!get_property_boolean("_fancyHotDogEaten") && availableFullness() > 0 && __misc_state["VIP available"] && __misc_state["can eat just about anything"] && $item[Clan hot dog stand].is_unrestricted()) { //too expensive to use outside a run? well, more that it's information overload
        
        string name = "Fancy hot dog edible";
        string [int] description;
        string image_name = "basic hot dog";
        
        string [int][int] options;
        options.listAppend(generateHotDogLine("Optimal Dog", "Semi-rare next adventure.", 1));
        
        if (__misc_state["in run"]) {
            options.listAppend(generateHotDogLine("Ghost Dog", "-combat, 30 turns.", 3));
            options.listAppend(generateHotDogLine("Video Game Hot Dog", "+25% item, +25% meat, pixels, 50 turns.", 3));
            options.listAppend(generateHotDogLine("Junkyard dog", "+combat, 30 turns.", 3));
            if (!__quest_state["Level 8"].finished || __quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
                options.listAppend(generateHotDogLine("Devil dog", "+3 cold/spooky res, 30 turns.", 3));
            if (!__quest_state["Level 9"].state_boolean["Peak Stench Completed"])
                options.listAppend(generateHotDogLine("Chilly dog", "+10ML and +3 stench/sleaze res, 30 turns.", 3));
            if (my_primestat() == $stat[muscle])
                options.listAppend(generateHotDogLine("Savage macho dog", "+50% muscle, 50 turns.", 2));
            if (my_primestat() == $stat[mysticality])
                options.listAppend(generateHotDogLine("One with everything", "+50% mysticality, 50 turns.", 2));
            if (my_primestat() == $stat[moxie])
                options.listAppend(generateHotDogLine("Sly Dog", "+50% moxie, 50 turns.", 2));
            if (__misc_state["need to level"] && __misc_state["Chateau Mantegna available"] && !$skill[Dog Tired].have_skill())
                options.listAppend(generateHotDogLine("Sleeping dog", "5 free rests/day (stats at chateau)", 2));
        }
            
        description.listAppend(HTMLGenerateSimpleTableLines(options));
        resource_entries.listAppend(ChecklistEntryMake(image_name, "clan_viplounge.php?action=hotdogstand", ChecklistSubentryMake(name, "", description), 5));
    }
    
        
    if (!get_property_boolean("_olympicSwimmingPoolItemFound") && __misc_state["VIP available"] && $item[Olympic-sized Clan crate].is_unrestricted())
        resource_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "", ChecklistSubentryMake("Dive for swimming pool item", "", "\"swim item\" in GCLI"), 5));
    if (!get_property_boolean("_olympicSwimmingPool") && __misc_state["VIP available"] && $item[Olympic-sized Clan crate].is_unrestricted())
        resource_entries.listAppend(ChecklistEntryMake("__item inflatable duck", "clan_viplounge.php?action=swimmingpool", ChecklistSubentryMake("Swim in VIP pool", "50 turns", listMake("+20 ML, +30% init", "Or -combat")), 5));
    if (!get_property_boolean("_aprilShower") && __misc_state["VIP available"] && $item[Clan shower].is_unrestricted()) {
        string [int] description;
        if (__misc_state["need to level"])
            description.listAppend("+mainstat gains. (50 turns)");
        
        string [int] reasons;
        if ($item[double-ice cap].available_amount() == 0)
            reasons.listAppend("nice hat");
        if ($familiar[fancypants scarecrow].familiar_is_usable() && $item[double-ice britches].available_amount() == 0)
            reasons.listAppend("scarecrow pants");
        //if (!__quest_state["Level 13"].state_boolean["past tower monsters"]) //don't think this is true
            //reasons.listAppend("situational tower killing");
        
        if (reasons.count() > 0)
            description.listAppend("Double-ice. (" + reasons.listJoinComponents(", ", "and") + ")");
        else
            description.listAppend("Double-ice.");
        
        resource_entries.listAppend(ChecklistEntryMake("__item shard of double-ice", "clan_viplounge.php?action=shower", ChecklistSubentryMake("Take a shower", description), 5));
    }
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 && $item[Clan pool table].is_unrestricted()) {
        int games_available = 3 - get_property_int("_poolGames");
        string [int] description;
        if (__misc_state["familiars temporarily blocked"])
            description.listAppend("+50% weapon damage. (aggressively)");
        else
            description.listAppend("+5 familiar weight, +50% weapon damage. (aggressively)");
        description.listAppend("Or +50% spell damage, +10 MP regeneration. (strategically)");
        description.listAppend("Or +10% item, +50% init. (stylishly)");
        resource_entries.listAppend(ChecklistEntryMake("__item pool cue", "clan_viplounge.php?action=pooltable", ChecklistSubentryMake(pluralise(games_available, "pool table game", "pool table games"), "10 turns", description), 5));
    }
    if (__quest_state["Level 6"].finished && !get_property_boolean("friarsBlessingReceived")) {
        string [int] description;
        if (!__misc_state["familiars temporarily blocked"]) {
            description.listAppend("+Familiar experience.");
            description.listAppend("Or +30% food drop.");
        }
        else
            description.listAppend("+30% food drop.");
        description.listAppend("Or +30% booze drop.");
        boolean should_output = true;
        if (!__misc_state["in run"] || my_path_id() == PATH_COMMUNITY_SERVICE) {
            should_output = false;
        }
        if (!should_output && familiar_weight(my_familiar()) < 20 && my_familiar() != $familiar[none]) {
            description.listClear();
            description.listAppend("+Familiar experience.");
            should_output = true;
        }
        if (should_output)
            resource_entries.listAppend(ChecklistEntryMake("Monk", "friars.php", ChecklistSubentryMake("Forest Friars buff", "20 turns", description), 10));
    }
    
    
    
    
    
    
    if (!get_property_boolean("_madTeaParty") && __misc_state["VIP available"] && $item[Clan looking glass].is_unrestricted()) {
        string [int] description;
        string line = "Various effects.";
        if (__misc_state["in run"] && my_path_id() != PATH_ZOMBIE_SLAYER && $item[pail].available_amount() > 0) {
            line = "+20ML";
            line += "|Or various effects.";
        }
        description.listAppend(line);
        resource_entries.listAppend(ChecklistEntryMake("__item insane tophat", "", ChecklistSubentryMake("Mad tea party", "30 turns", description), 5));
    }
    
    if (true) {
        string image_name = "__item hell ramen";
        ChecklistSubentry [int] subentries;
        int importance = 11;
        if (availableFullness() > 0) {
            string [int] description;
            if ($effect[Got Milk].have_effect() > 0)
                description.listAppend(pluralise($effect[Got Milk]) + " available (woah).");
            if (!get_property_boolean("_milkOfMagnesiumUsed") && lookupItem("milk of magnesium").available_amount() > 0)
                description.listAppend("Use Milk of Magnesium for +5 adv.");
            subentries.listAppend(ChecklistSubentryMake(availableFullness() + " fullness", "", description));
        }
        if (inebriety_limit() > 0) {
            boolean stooperIsEquipped = my_familiar() == lookupFamiliar("Stooper");
            boolean couldEquipStooper = lookupFamiliar("Stooper").familiar_is_usable() && !stooperIsEquipped;
            string title = "";
            string [int] description;
            if (availableDrunkenness() >= 0) {
                boolean shotglassDrinkAvailable = !get_property_boolean("_mimeArmyShotglassUsed") && lookupItem("mime army shotglass").is_unrestricted() && lookupItem("mime army shotglass").available_amount() > 0;
                if (subentries.count() == 0)
                    image_name = "__item gibson";
                if ($effect[ode to booze].have_effect() > 0)
                    description.listAppend(pluralise($effect[ode to booze]) + " available.");
                
                if (availableDrunkenness() > 0)
                    title = availableDrunkenness() + " drunkenness" + (couldEquipStooper ? " + Stooper" : "");
                else {
                    title = "Can overdrink";
                    if (couldEquipStooper)
                        description.listAppend("Could equip Stooper for +1 drunkenness.");
                }
                if (shotglassDrinkAvailable)
                    description.listAppend("1 free 1-drunkenness booze available.");
            } else if (availableDrunkenness() == -1 && couldEquipStooper) {
                importance = -11;
                title = HTMLGenerateSpanFont("Equip the Stooper", "red");
                image_name = "__familiar stooper";
                description.listAppend("Can keep adventuring/overdrink further as long as it's equipped.");
            }
            if (description.count() > 0)
                subentries.listAppend(ChecklistSubentryMake(title, "", description));
        }
        if (availableSpleen() > 0) {
            if (subentries.count() == 0)
                image_name = "__item agua de vida";
            subentries.listAppend(ChecklistSubentryMake(availableSpleen() + " spleen", "", ""));
        }
        if (subentries.count() > 0)
            resource_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=1", subentries, importance));
    }
    
    if (__quest_state["Level 13"].state_boolean["king waiting to be freed"]) {
        string [int] description;
        description.listAppend("Contains one (1) monarch.");
        description.listAppend(pluralise(my_ascensions(), "king", "kings") + " freed." + (my_ascensions() > 250 ? " Collect them all!" : ""));
        string image_name;
        image_name = "__effect sleepy";
        resource_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=nstower", ChecklistSubentryMake("1 Prism", "", description), 10));
    }
    
    if ((get_property("sidequestOrchardCompleted") == "hippy" || get_property("sidequestOrchardCompleted") == "fratboy") && !get_property_boolean("_hippyMeatCollected")) {
        resource_entries.listAppend(ChecklistEntryMake("__item herbs", "island.php", ChecklistSubentryMake("Meat from the hippy store", "", "~4500 free meat."), 5)); //FIXME consider shop.php?whichshop=hippy
    }
    if ((get_property("sidequestArenaCompleted") == "hippy" || get_property("sidequestArenaCompleted") == "fratboy") && !get_property_boolean("concertVisited")) {
        string [int] description;
        if (get_property("sidequestArenaCompleted") == "hippy") {
            if (!__misc_state["familiars temporarily blocked"])
                description.listAppend("+5 familiar weight.");
            description.listAppend("Or +20% item.");
            if (__misc_state["need to level"])
                description.listAppend("Or +5 stats/fight.");
        } else if (get_property("sidequestArenaCompleted") == "fratboy") {
            description.listAppend("+40% meat.");
            description.listAppend("+50% init.");
            description.listAppend("+10% all attributes.");
        }
        
        string url = "bigisland.php?place=concert";
        if (__quest_state["Level 12"].finished)
            url = "postwarisland.php?place=concert";
        resource_entries.listAppend(ChecklistEntryMake("__item the legendary beat", url, ChecklistSubentryMake("Arena concert", "20 turns", description), 5));
    }
    
    //Not sure how I feel about this. It's kind of extraneous?
    if (get_property_int("telescopeUpgrades") > 0 && !get_property_boolean("telescopeLookedHigh") && __misc_state["in run"] && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING && !in_bad_moon() && my_path_id() != PATH_NUCLEAR_AUTUMN) {
        string [int] description;
        int percentage = 5 * get_property_int("telescopeUpgrades");
        description.listAppend("+" + (percentage == 25 ? "35% or +25" : percentage) + "% to all attributes. (10 turns)");
        resource_entries.listAppend(ChecklistEntryMake("__effect Starry-Eyed", "campground.php?action=telescope", ChecklistSubentryMake("Telescope buff", "", description), 10));
    }
    
    
    if (__misc_state_int["free rests remaining"] > 0) {
        ChecklistEntry entry;
        entry.image_lookup_name = "__effect sleepy";
        entry.importance_level = 10;

        //Build the entries in an order dependant on user preferences
        boolean go_chateau = get_property_boolean("restUsingChateau");
        boolean go_away = get_property_boolean("restUsingCampAwayTent");
        string [int] order;
        order [go_chateau ? 0 : 1] = "Chateau Magenta";
        order [go_chateau ? 1 : 0] = go_away ? "Getaway Campsite" : "Your Campsite";
        order [2] = go_away ? "Your Campsite" : "Getaway Campsite";


        string [int] url;
        ChecklistSubentry [int] subentries_handle;
        string [int] description;

        foreach i, loc in order {
            ChecklistSubentry subentry;
            switch {
                case loc == "Chateau Magenta" && __misc_state["Chateau Mantegna available"]:
                    subentry.header = "At your Chateau Magenta:";
                    url.listAppend(__misc_state_string["resting url Chateau Mantegna"]);

                    stat nightstand_stat = $stat[none];
                    int [item] chateau = get_chateau();

                    if (chateau[$item[electric muscle stimulator]] > 0)
                        nightstand_stat = $stat[muscle];
                    else if (chateau[$item[foreign language tapes]] > 0)
                        nightstand_stat = $stat[mysticality];
                    else if (chateau[$item[bowl of potpourri]] > 0)
                        nightstand_stat = $stat[moxie];

                    subentry.entries.listAppend("250 HP, 125 MP" + (my_path_id() == PATH_THE_SOURCE || nightstand_stat == $stat[none] ? "" : ", " + clampi(12 * my_level(), 0, 100) + " " + nightstand_stat + " stats") + ".");
                    
                    if (my_level() < 9 && my_path_id() != PATH_THE_SOURCE)
                        subentry.entries.listAppend("May want to wait until level 9(?) for more stats from resting.");
                    
                    item [int] items_equipping = generateEquipmentToEquipForExtraExperienceOnStat(nightstand_stat);
                    if (items_equipping.count() > 0 && __misc_state["need to level"])
                        subentry.entries.listAppend("Could equip " + items_equipping.listJoinComponents(", ", "or") + " for more stats.");

                    subentries_handle.listAppend(subentry);
                    break;
                case loc == "Getaway Campsite" && __misc_state["Getaway Campsite available"]:
                    subentry.header = "At your Getaway Campsite:";
                    url.listAppend(__misc_state_string["resting url Getaway Campsite"]);

                    int tent_decoration = get_property_int("campAwayDecoration");
                    effect tent_decoration_effect = $effect[none]; //Not actually used...
                    string tent_decoration_stat;

                    switch (tent_decoration) {
                        case 1:
                            tent_decoration_effect = $effect[Muscular Intentions];
                            tent_decoration_stat = "muscle";
                            break;
                        case 2:
                            tent_decoration_effect = $effect[Mystical Intentions];
                            tent_decoration_stat = "myst";
                            break;
                        case 3:
                            tent_decoration_effect = $effect[Moxious Intentions];
                            tent_decoration_stat = "moxie";
                            break;
                    }
                    
                    subentry.entries.listAppend("250 HP, 125 MP, removes negative effects.");

                    if (tent_decoration != 0)
                        subentry.entries.listAppend("Gives 20 turns of +3 " + tent_decoration_stat + " stats/fight.");

                    subentries_handle.listAppend(subentry);
                    break;
                case loc == "Your Campsite" && __misc_state["recommend resting at campsite"]:
                    subentry.header = "At your Campsite:";
                    url.listAppend(__misc_state_string["resting url campsite"]);
                    
                    subentry.entries.listAppend(__misc_state_int["rest hp restore"] + " HP, " + __misc_state_int["rest mp restore"] + " MP.");
                    if ($item[pantsgiving].available_amount() > 0) {
                        if ($item[pantsgiving].equipped_amount() == 0)
                            subentry.entries.listAppend("Wear pantsgiving for extra HP/MP.");
                        if (availableFullness() > 0)
                            subentry.entries.listAppend("Eat more for +" + (availableFullness() * 5) + " extra HP/MP.");
                    }

                    if (__resting_bonuses.count() > 0) {
                        boolean saw_a_limit;
                        string [int] bonus_messages;
                        foreach source, bonus in __resting_bonuses {
                            string message;

                            if (bonus.header == "")
                                message += "Unlisted furniture '" + source + "'";
                            else if (source == $item[Confusing LED clock] && my_adventures() < 5)
                                continue; //won't activate
                            else {
                                if (bonus.duration > 0) {
                                    if (source == $item[Lucky cat statue]) //SETS the remaining duration of that effect to 5 adv
                                        message += pluralise(bonus.duration - bonus.given_effect.have_effect(), "turn", "turns") + " of ";
                                    else if (bonus.tasteful && bonus.given_effect.have_effect() > 1)
                                        continue; //won't activate
                                    else
                                        message += bonus.duration.pluralise("turn", "turns") + " of ";
                                }

                                message += bonus.given_effect == $effect[none] ? bonus.header : bonus.given_effect + " (" + bonus.header + ")";

                                if (bonus.limit > 0) {
                                    saw_a_limit = true;
                                    message += ", " + bonus.limit + (bonus.limit > 1 ? "x" : "") + "/day";
                                }

                                //if (bonus.tasteful) //player should already be well aware of this; not relevant
                                //  message += ", breaks after 3-5 uses";

                                message += ".";
                            }

                            bonus_messages.listAppend(message);
                        }

                        if (saw_a_limit) //tell the player that the tiles don't mean that the buffs are still obtainable today; we can't know if they reached the limits
                            subentry.modifiers.listAppend("Can't tell if you got them, sorry...");
                        
                        if (bonus_messages.count() > 1)
                            subentry.entries.listAppend("Will give:" + HTMLGenerateIndentedText(bonus_messages.listJoinComponents("<hr>")));
                        else if (bonus_messages.count() == 1)
                            subentry.entries.listAppend("Will give " + bonus_messages[0]);
                    }

                    subentries_handle.listAppend(subentry);
                    break;
            }
        }

        entry.url = url [0];

        if (subentries_handle.count() > 1) {
            entry.should_indent_after_first_subentry = true; //that feature is awesome!
            entry.subentries = subentries_handle;
            entry.subentries.listPrepend(ChecklistSubentryMake(pluraliseWordy(__misc_state_int["free rests remaining"], "free rest", "free rests").capitaliseFirstLetter()));
        } else if (subentries_handle.count() == 1)
            entry.subentries.listAppend(ChecklistSubentryMake(pluraliseWordy(__misc_state_int["free rests remaining"], "free rest", "free rests").capitaliseFirstLetter(), "", subentries_handle[0].entries));

        resource_entries.listAppend(entry);
    }
    
    //FIXME skate park?
    
    if (my_path_id() != PATH_BEES_HATE_YOU && !get_property_boolean("guyMadeOfBeesDefeated") && get_property_int("guyMadeOfBeesCount") > 0 && (__misc_state["in aftercore"] || !__quest_state["Level 12"].state_boolean["Arena Finished"])) {
        //Not really worthwhile? But I suppose we can track it if they've started it, and are either in aftercore or haven't flyered yet.
        //For flyering, it's 20 turns at -25%, 25 turns at -15%. 33 turns at -5%. Not worthwhile?
        int summon_count = get_property_int("guyMadeOfBeesCount");
        
        string [int] description;
        string times = "";
        if (summon_count == 4)
            times = "One More Time.";
        else
            times = int_to_wordy(5 - summon_count) + " times.";
        description.listAppend("Speak his name " + times);
        if ($item[antique hand mirror].available_amount() == 0)
            description.listAppend("Need antique hand mirror to win. Or towerkill.");
        resource_entries.listAppend(ChecklistEntryMake("__item guy made of bee pollen", $location[the haunted bathroom].getClickableURLForLocation(), ChecklistSubentryMake("The Guy Made Of Bees", "", description), 10));
    }
    
    if (stills_available() > 0) {
        string [int] description;
        string [int] mixables;
        if (__misc_state["can drink just about anything"] && my_path_id() != PATH_SLOW_AND_STEADY) {
            mixables.listAppend("neuromancer-level drinks");
        }
        mixables.listAppend("~40MP from tonic water");
        
        description.listAppend(mixables.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
        
        resource_entries.listAppend(ChecklistEntryMake("Superhuman Cocktailcrafting", "shop.php?whichshop=still", ChecklistSubentryMake(pluralise(stills_available(), "still use", "still uses"), "", description), 10));
    }
    
    if (__last_adventure_location == $location[The Red Queen\'s Garden]) {
        string will_need_effect = "";
        if ($effect[down the rabbit hole].have_effect() == 0)
            will_need_effect = "|Will need to use &quot;DRINK ME&quot; potion first.";
        if (get_property_int("pendingMapReflections") > 0)
            resource_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "place.php?whichplace=rabbithole", ChecklistSubentryMake(pluralise(get_property_int("pendingMapReflections"), "pending reflection of a map", "pending reflections of a map"), "+900% item", "Adventure in the Red Queen's garden to acquire." + will_need_effect), 0));
        if ($items[reflection of a map].available_amount() > 0) {
            resource_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "inventory.php?ftext=reflection+of+a+map", ChecklistSubentryMake(pluralise($item[reflection of a map]), "", "Queen cookies." + will_need_effect), 0));
        }
    }
    
    if (__misc_state["VIP available"]) {
        if (!get_property_boolean("_lookingGlass") && $item[Clan looking glass].is_unrestricted()) {
            resource_entries.listAppend(ChecklistEntryMake("__item &quot;DRINK ME&quot; potion", "clan_viplounge.php?whichfloor=2", ChecklistSubentryMake("A gaze into the looking glass", "", "Acquire a " + $item[&quot;DRINK ME&quot; potion] + "."), 10));
        }
        //_deluxeKlawSummons?
        //_crimboTree?
        int soaks_remaining = __misc_state_int["hot tub soaks remaining"];
        if (__misc_state["in run"] && soaks_remaining > 0 && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING && my_path_id() != PATH_VAMPIRE) {
            string description = "Restore all HP, removes most bad effects.";
            resource_entries.listAppend(ChecklistEntryMake("__effect blessing of squirtlcthulli", "clan_viplounge.php", ChecklistSubentryMake(pluralise(soaks_remaining, "hot tub soak", "hot tub soaks"), "", description), 8));
        }
        
        
    }
    //_klawSummons?
    
    //Skill books we have used, but don't have the skill for?
    
    //soul sauce tracking?
    
    if ($item[can of rain-doh].available_amount() > 0 && $item[empty rain-doh can].available_amount() == 0 && __misc_state["in run"]) {
        resource_entries.listAppend(ChecklistEntryMake("__item can of rain-doh", "inventory.php?ftext=can+of+rain-doh", ChecklistSubentryMake("Can of Rain-Doh", "", "Open it!"), 0));
    }
    
    
    
    if (get_property_int("goldenMrAccessories") > 0) {
        //FIXME inline with hugs
        int total_casts_available = get_property_int("goldenMrAccessories") * 5;
        int casts_used = get_property_int("_smilesOfMrA");
        
        int casts_remaining = total_casts_available - casts_used;
        
        if (casts_remaining > 0) {
            string image_name = "__item Golden Mr. Accessory";
            if (my_id() == 1043600)
                image_name = "__item defective Golden Mr. Accessory"; //does not technically give out sunshine, but...
            resource_entries.listAppend(ChecklistEntryMake(image_name, "skills.php", ChecklistSubentryMake(pluralise(casts_remaining, "smile of the Mr. Accessory", "smiles of the Mr. Accessory"), "", "Give away sunshine."), 8));
        }
    }
    
    if (__misc_state["Chateau Mantegna available"] && !get_property_boolean("_chateauDeskHarvested")) {
        string image_name = "__item fancy calligraphy pen";
        resource_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=chateau", ChecklistSubentryMake("Chateau desk openable", "", "Daily collectable."), 8));
    }

    if (!get_property_boolean("_lyleFavored")) {
        string image_name = "__effect favored by lyle";
        string description = $effect[Favored by Lyle].have_effect() > 0 ? "Increases duration of Favored by Lyle." : "+10% all attributes.";
        resource_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=monorail", ChecklistSubentryMake("Visit Lyle", "10 turns", description), 10));
    }
    
    checklists.listAppend(ChecklistMake("Resources", resource_entries));
}
