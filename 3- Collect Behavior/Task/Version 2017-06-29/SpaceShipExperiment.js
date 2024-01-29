$(document).ready(function () {

    // Initial Display Parameters
    thisHeight = $(document).height() * .9;
    thisWidth = thisHeight * 4 / 3;
    
    DispWidth = thisHeight * 5 / 6;
    DispHeight = DispWidth / 2;
    
    ConfWidth = thisHeight * 4 / 6;
    ConfHeight = ConfWidth / 2;


    $('#Main').css('min-height', thisHeight);
    $('#Main').css('width', thisWidth);
    
    
    // Get intergalactic planet images
    if (Math.random() > 0.5)    {
        In_planet_Img1 = 'Planet_Gray.png';     In_planet_1_name = 'Gray Dust';
        In_planet_Img2 = 'Planet_Brown.png';    In_planet_2_name = 'Brown Dust';
    }    else    {
        In_planet_Img1 = 'Planet_Brown.png';    In_planet_1_name = 'Brown Dust';
        In_planet_Img2 = 'Planet_Gray.png';     In_planet_2_name = 'Gray Dust';
    };
    
    
    // Get EXtragalactic planet images
    if (Math.random() > 0.5)    {
        Ex_planet_Img1 = 'Planet_Blue.png';     Ex_planet_1_name = 'Helium Blue';
        Ex_planet_Img2 = 'Planet_Red.png';      Ex_planet_2_name = 'Helium Red';
    }    else    {
        Ex_planet_Img1 = 'Planet_Blue.png';     Ex_planet_1_name = 'Helium Red';
        Ex_planet_Img2 = 'Planet_Blue.png';     Ex_planet_2_name = 'Helium Blue';
    };
    
    
    // Get spaceship images 
    if (Math.random() > 0.5)    {
        Spaceship_Img1 = 'SpaceShip_B.png'; 
        Spaceship_Img2 = 'SpaceShip_R.png';
    }    else    {
        Spaceship_Img1 = 'SpaceShip_R.png'; 
        Spaceship_Img2 = 'SpaceShip_B.png'; 
    };
    
    
    // Creating the htmls for the objects 
    var html_Plan_Earth     = '<img id = "id_Plan_Earth" src="images/Planet_Earth.png"        width = "' + thisHeight * 0.18 + '"  class="img-responsive center-block" >';
    
    var html_In_plan_1      = '<img id = "id_In_plan_1" src="images/'  + In_planet_Img1 + '"  width = "' + thisHeight * 0.16 + '"  class="img-responsive center-block" >';
    var html_In_plan_2      = '<img id = "id_In_plan_2" src="images/'  + In_planet_Img2 + '"  width = "' + thisHeight * 0.16 + '"  class="img-responsive center-block" >';
    
    var html_Ex_plan_1      = '<img id = "id_Ex_plan_1" src="images/'  + Ex_planet_Img1 + '"  width = "' + thisHeight * 0.2 + '"  class="img-responsive center-block" >';
    var html_Ex_plan_2      = '<img id = "id_Ex_plan_2" src="images/'  + Ex_planet_Img2 + '"  width = "' + thisHeight * 0.2 + '"  class="img-responsive center-block" >';
    
    var html_rocket_1       = '<img id = "id_rocket_1"  src="images/'  + Spaceship_Img1 + '"  width = "' + thisHeight * 0.13 + '"  class="img-responsive center-block" >';
    var html_rocket_2       = '<img id = "id_rocket_2"  src="images/'  + Spaceship_Img2 + '"  width = "' + thisHeight * 0.13 + '"  class="img-responsive center-block" >';
    
    var html_portal         = '<img id = "id_portal"  src="images/Portal.gif "              width = "' + thisHeight * 0.3 + '"  class="img-responsive center-block" >'; // non rotating portal 
    var html_portal_rotate  = '<img id = "id_portal"  src="images/Portal_rotating.gif "     width = "' + thisHeight * 0.3 + '"  class="img-responsive center-block" >';


    var html_Sad_Face       = '<img id = "id_Sad_Face" src="images/Sad.png"         width = "' + thisHeight * 0.4 + '"  class="img-responsive center-block" >';

    
    // CHOOSE TO IGNORE THE INTRODUCTION FUNCTIONS !
    var TrialNum = 1;
    setTimeout(function () {
	Step_1(TrialNum); // SKIP information sheet go to 
        //        Information();//Start with information sheet
    },10);
    
    
    // The actual experimment 

    // Step_1: choosing a spaceship
    function Step_1(TrialNum) {
        console.log("function Step_1");
        $('#Stage').empty();
        $('#Top').css('height', thisHeight / 20);
        $('#Stage').css('width', DispWidth * 1.4);
        $('#Stage').css('min-height', thisHeight * 17 / 20);
        $('#Bottom').css('min-height', thisHeight / 20);

        // the text
        CreateDiv('Stage', 'TextBoxDiv');
        var Title = '<div id = "Title"><H2 align = "center">Choose a Rocket</H2></div>';
        $('#TextBoxDiv').html(Title);
        
        // Create a row division (one of three) for in planets to planeced in, there should be two more fore spaceships and earth 
        CreateDiv('Stage', 'sub_stage_top');
        $('#sub_stage_top').addClass('row');
        $('#sub_stage_top').css('height', DispWidth * 0.25);  
        // display in planet 1 
        CreateDiv('sub_stage_top', 'id_in_planet_1');
        $('#id_in_planet_1').addClass('col-xs-6');
        $('#id_in_planet_1').html(html_In_plan_1);
        $('#id_in_planet_1').css('margin', 'auto');
        $('#id_in_planet_1').show();
        // display in planet 2
        CreateDiv('sub_stage_top', 'id_in_planet_2');
        $('#id_in_planet_2').addClass('col-xs-6');
        $('#id_in_planet_2').html(html_In_plan_2);
        $('#id_in_planet_2').css('margin', 'auto');
        $('#id_in_planet_2').show();
        
        
        // Creat the middle row for spaceships 
        CreateDiv('Stage', 'sub_stage_middle');
        $('#sub_stage_middle').addClass('row');
        $('#sub_stage_middle').css('height', DispWidth * 0.25);        
        $('#sub_stage_middle').css('margin', 'auto');
        // display Rocket 1
        CreateDiv('sub_stage_middle', 'id_rocket_1');
        $('#id_rocket_1').addClass('col-xs-6');
        $('#id_rocket_1').html(html_rocket_1);
        $('#id_rocket_1').css('margin', 'auto');
        $('#id_rocket_1').show();
        // display Rocket 2
        CreateDiv('sub_stage_middle', 'id_rocket_2');
        $('#id_rocket_2').addClass('col-xs-6');
        $('#id_rocket_2').html(html_rocket_2);
        $('#id_rocket_2').css('margin', 'auto');
        $('#id_rocket_2').show();
        
        
        // Creat the bottom row for spaceships
        CreateDiv('Stage', 'sub_stage_bottom');
        $('#sub_stage_bottom').addClass('row');
        $('#sub_stage_bottom').css('height', DispWidth * 0.25);        
        $('#sub_stage_bottom').css('margin', 'auto');
        // Display earth 
        CreateDiv('sub_stage_bottom', 'id_Plan_Earth');
        $('#id_Plan_Earth').addClass('col-xs-12');
        $('#id_Plan_Earth').html(html_Plan_Earth);
        $('#id_Plan_Earth').css('margin', 'auto');
        $('#id_Plan_Earth').show();
        
        // selfexplanatory, tic set to current time 
        tic = (new Date()).getTime(); // for RT of choosing spaceship 

        
        // time constraint 
        var Not_pressed = true; // this is to stop the time constraint once the key is pressed 
       
//        setTimeout(function () {
//            if (Not_pressed) {    
//                Step_MissedIt(TrialNum);
//            }
//        }, 1000);

        
        // Key press 
        $( "body" ).keydown(function(e) {
            
            var k = e.keyCode; // get the key code of what was pressed 
            if (k === 49){
                Not_pressed = false; 
                //                alert( "N 1 pressed ");
                RT = (new Date()).getTime() - tic;
                $('#id_rocket_1').css({"border-color": "#d7f0fd",
                    "border-width": "5px","border-style": "solid",
                    "border-radius": "10px"});
                            
                setTimeout(function () {
                    Step_2(TrialNum,1);
                }, 50);

            } else if (k === 48) {
                Not_pressed = false; 
                //                alert( "N 2 pressed ");
                RT = (new Date()).getTime() - tic;
                $('#id_rocket_2').css({"border-color": "#d7f0fd",
                    "border-width": "5px","border-style": "solid",
                    "border-radius": "10px"});
                
                setTimeout(function () {
                    Step_2(TrialNum,2);
                }, 500);

            };
        });
        
        
        

        
        

        /// HAVENT DELETE THESE TO USE THE SETTIMOUT BIT 

        //        // take response 
        //        $('#Advisor1').click(function () {
        //            RT = (new Date()).getTime() - tic; // for RT of choosing adviser
        //            $(this).css({"border-color": "#d7f0fd",
        //                "border-width": "5px",
        //                "border-style": "solid",
        //                "border-radius": "10px"});
        //
        //            
        //            setTimeout(function () {
        //                document.getElementById("Advisor1").onclick = function () {
        //                    return false;
        //                };
        //                WaitForAdviser(TrialNum, 1);
        //            }, 1000);
        //            
        //        });

        $('#Advisor2').click(function () {
            
            $('#Advisor2').click(false);
            RT = (new Date()).getTime() - tic; // for RT of choosing adviser
            $(this).css({"border-color": "#d7f0fd",
                "border-width": "5px",
                "border-style": "solid",
                "border-radius": "10px"});
            console.log("Advisor2 chosen");

            setTimeout(function () {
                document.getElementById("Advisor2").onclick = function () {
                    return false;
                };
                WaitForAdviser(TrialNum, 2);
            }, 1000);
            
        });

    }



    function Step_2(TrialNum,planet) {
        console.log("Step_2");
        $('#Stage').empty();
        $('#Top').css('height', thisHeight / 20);
        $('#Stage').css('width', DispWidth * 1.4);
        $('#Stage').css('min-height', thisHeight * 17 / 20);
        $('#Bottom').css('min-height', thisHeight / 20);
        
        
        if(planet===1){
            
            // take planet 1 
            var Title = '<div id = "Title"><H2 align = "center"> You are on planet ' + In_planet_1_name + '</H2></div>';
            var html_In_plan = html_In_plan_1;

        } else {
            
            // tale planet 2 
            var Title = '<div id = "Title"><H2 align = "center"> You are on planet ' + In_planet_2_name + '</H2></div>';
            var html_In_plan = html_In_plan_2;
        };
        
        
        
        CreateDiv('Stage', 'TextBoxDiv');
        $('#TextBoxDiv').html(Title);

        // show the portal 
        CreateDiv('Stage', 'sub_stage_top');
        $('#sub_stage_top').addClass('row');
        $('#sub_stage_top').css('height', DispWidth * 0.4);  
        // display inportal  
        CreateDiv('sub_stage_top', 'id_portal');
        $('#id_portal').addClass('col-xs-12');
        $('#id_portal').html(html_portal_rotate);
        $('#id_portal').css('margin', 'auto');
        $('#id_portal').show();
        
        
        // place the intergalactic planet here 
        CreateDiv('Stage', 'sub_stage_middle');
        $('#sub_stage_middle').addClass('row');
        $('#sub_stage_middle').css('height', DispWidth * 0.4);  
        // display the planet that was chosen 
        CreateDiv('sub_stage_middle', 'id_in_planet');
        $('#id_in_planet').addClass('col-xs-12');
        $('#id_in_planet').html(html_In_plan);
        $('#id_in_planet').css('height', thisHeight * 0.3);
        $('#id_in_planet').css('margin', 'auto');
        $('#id_in_planet').show();
        
        
        
        // Key press
        $( "body" ).keydown(function(e) {
            var k = e.keyCode; // get the key code of what was pressed 
            if (k ===32){
                // Any visual changes once space is pressed           

                e = null;
                Step_3(TrialNum,planet);
                
                // wait a bit before moving 
                //            setTimeout(function () {
                //                Step_3(TrialNum,1);
                //            }, 1000);
            };
        });
        
        
        
    }
        
        
        
    function Step_3(TrialNum,planet) {
        console.log("Step_3");
        $('#Stage').empty();
        $('#Top').css('height', thisHeight / 20);
        $('#Stage').css('width', DispWidth * 1.4);
        $('#Stage').css('min-height', thisHeight * 17 / 20);
        $('#Bottom').css('min-height', thisHeight / 20);
        
        
        if(planet===1){
            
            // take planet 1 
            var Title = '<div id = "Title"><H2 align = "center"> Portal took you to ' + Ex_planet_1_name + '</H2></div>';
            var html_Ex_plan = html_Ex_plan_1;
            
        } else {
            
            // tale planet 2 
            var Title = '<div id = "Title"><H2 align = "center"> Portal took you to ' + Ex_planet_2_name + '</H2></div>';
            var html_Ex_plan = html_Ex_plan_2;
        };
        
        
        
        CreateDiv('Stage', 'TextBoxDiv');
        $('#TextBoxDiv').html(Title);
        
        // show the portal 
        CreateDiv('Stage', 'sub_stage_top');
        $('#sub_stage_top').addClass('row');
        $('#sub_stage_top').css('height', DispWidth * 0.4);  
        // dsiplay reward !  
        //        CreateDiv('sub_stage_top', 'reward');
        //        $('#reward').addClass('col-xs-12');
        //        $('#reward').html(html_reward);
        //        $('#reward').css('margin', 'auto');
        //        $('#reward').show();
        
        
        // place the intergalactic planet here 
        CreateDiv('Stage', 'sub_stage_middle');
        $('#sub_stage_middle').addClass('row');
        $('#sub_stage_middle').css('height', DispWidth * 0.4);  
        // display the planet that was chosen 
        CreateDiv('sub_stage_middle', 'id_ex_planet');
        $('#id_ex_planet').addClass('col-xs-12');
        $('#id_ex_planet').html(html_Ex_plan);
        $('#id_ex_planet').css('height', thisHeight * 0.3);
        $('#id_ex_planet').css('margin', 'auto');
        $('#id_ex_planet').show();
        
        
        
        // Key press
        $( "body" ).keydown(function(e) {
            var k = e.keyCode; // get the key code of what was pressed 
            if (k ===32){
                // Any visual changes once space is pressed           


                Step_1(TrialNum);
                
                // wait a bit before moving 
                //            setTimeout(function () {
                //                Step_3(TrialNum,1);
                //            }, 1000);
            };
        });
        
        
        
    }
    
    
    
    function Step_MissedIt(TrialNum) {
        console.log("Step_MissedIt");
        $('#Stage').empty();
        $('#Top').css('height', thisHeight / 20);
        $('#Stage').css('width', DispWidth * 1.4);
        $('#Stage').css('min-height', thisHeight * 17 / 20);
        $('#Bottom').css('min-height', thisHeight / 20);
        
        Not_pressed = false; 
        
        var Title = '<div id = "Title"><H2 align = "center"> You took long too long to repsond, try the next day \n\
                    press space to go to next day </H2></div>';
        
        CreateDiv('Stage', 'TextBoxDiv');
        $('#TextBoxDiv').html(Title);
        
        // show the portal 
        CreateDiv('Stage', 'sub_stage_top');
        $('#sub_stage_top').addClass('row');
        $('#sub_stage_top').css('height', DispWidth * 0.4);  
        // dsiplay reward !  
        CreateDiv('sub_stage_top', 'id_sad');
        $('#id_sad').addClass('col-xs-12');
        $('#id_sad').html(html_Sad_Face);
        $('#id_sad').css('margin', 'auto');
        $('#id_sad').show();
        
        
        
        // Key press
        $( "body" ).keydown(function(e) {
            var k = e.keyCode; // get the key code of what was pressed 
            if (k ===32){
                Step_1(TrialNum);
            };
        });
        
        
        
    }


    //Utility Functions
    function CreateDiv(ParentID, ChildID) {

        var d = $(document.createElement('div'))
                .attr("id", ChildID);
        var container = document.getElementById(ParentID);

        d.appendTo(container);
    }
    ;

});
