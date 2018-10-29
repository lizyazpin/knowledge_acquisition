
/***********************************
 * Dependencies
 */
:- register_ros_package(knowrob_common).
:- register_ros_package(knowrob_srdl).
:- register_ros_package(knowrob_cram).
:- register_ros_package(knowrob_vis).
:- register_ros_package(knowrob_robohow).


/***********************************
 * Include source files
 */
:- use_module(library('get_data')).

/***********************************
 * Parse OWL files
 */
:-owl_parse('package://knowrob_srdl/owl/PR2.owl').
:-owl_parse('package://knowrob_robohow/owl/robohow2016_picking.owl').

