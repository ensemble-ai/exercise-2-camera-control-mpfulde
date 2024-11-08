* Name: Andrew Fojas 
* Email: atfojas@ucdavis.edu

## Solution Assessment ##

### Stage 1 ###

- [X] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Position lock works as expected. Camera stays on top of target even when boosting. 

___
### Stage 2 ###

- [X] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Player vessel stays within the frame border box even as the camera permanenetly scrolls in a direction. Has all the required export fields and uses them.

___
### Stage 3 ###

- [X] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
Camera lerps to target vessel if vessel moves. The distance between the camera and vessel does not exceed a set leash distance. Has all the required export fields and uses them.

___
### Stage 4 ###

- [ ] Perfect
- [ ] Great
- [X] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
If I move in one direction (ie up down left right etc), the camera stays in front of the target. However, when I manuver in different directions, the camera won't move fast to be in front of the vessel (will appear behind the vessel for a significant amount of time). Lerp speed back is a little slow as well. Camera behavior is a little awkward with the current implementation. Has all the required export fields and uses them.

___
### Stage 5 ###

- [ ] Perfect
- [ ] Great
- [ ] Good
- [X] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
The outer push box is correctly set up to not let the vessel outside of the box. However there are some issues with the rest of the implementation. When the vessel is in the push zone and is not moving, the camera does not move in that direction. It only moves in the push zone when the vessel is moving when the camera should move in that direction reguardless of the vessel moving in the push zone. Furthermore, the inner push box boundary does not allign with the one in boundary box display for this camera. Has all the required export fields and uses them.
___

### Code Style Review ###

#### Style Guide Infractions ####
* [Surround functions with blank lines](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/position_lock.gd#L9) - Does not surround function/class definitions with two blank lines in a few places throughout the coder's implementation. The hyperlink is one example of such place.
* [Document comment spacing](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/speed_push_box.gd#L39) - Incorrectly does not add a space between comment symbol the documentation statement.



#### Style Guide Exemplars ####
* [Plain english boolean operators](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/speed_push_box.gd#L86) - Does not use plane english operators instead of boolean operators
* [Good indentation](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/speed_push_box.gd#L47) - Overall displays good indentation (no indentation faults), but particularly displayed well in this implemented function.
* [Code spacing](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/speed_push_box.gd#L46) - Line contains good spacing by separating the different aspects of the line of code making it more readable.
* Code order - Overall good code order, could not find any issues in the order of any file that was manipulated/created.


### Best Practices Review ###


#### Best Practices Infractions ####
* [Incorrect verb tense](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/position_lock_lerp.gd#L26) - Comment uses past tense when it should be present tense.
* [Articles (in this case "the") are omited](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/position_lock_lerp.gd#L62) - Comment at this line does use the article "the". It should read as "since [the] framerate..." rather than "since framerate..."  
* [Unclear comment](https://github.com/ensemble-ai/exercise-2-camera-control-mpfulde/blob/91e2278e8be00376654b25f7ce950bcc830e80c6/Obscura/scripts/camera_controllers/speed_push_box.gd#L12) - Comment is unclear, meaning I had trouble understanding what the below code was being used for just by looking at the comment.

#### Best Practices Exemplars ####
* Overall, pretty clear code and documentation: Displays consise and mostly easy-to-follow code and documentation. However, some areas, like the ones above, make their associated sections a little unclear.