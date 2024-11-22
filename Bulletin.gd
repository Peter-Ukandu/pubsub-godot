## A simple implementation of the Publisher-Subscriber proramming pattern.
##
## This autoload class uses a simple implementation of the Publisher-Subscriber
## programming pattern as an alternative to signals for processing and handling
## communication between objects in your game. Although signals are very
## powerful and easy to use, they can sometimes lead to coupling and force
## dependency of nodes, as to connect to a signal, the required signal must be
## known. The Publisher-Subscriber pattern loosens coupling between the objects
## by posting and recieving messages or events without the need to know where
## said event came from. It can be compared to a bulletin board where
## anonymous publishers post articles and subscribers filter out the articles of
## interest to them. This implementation uses a topic-based filtering system to
## filter out messages of interest to subscribers. It also adds tags to
## better fine-tune the messages that are recieved by a subscriber.
##
## Note: to handle posts, subscribers must have an _handle_post method
## within their script.

@icon("res://bulletin.svg")
extends Node

## contains all topics and posts associated with them.
var all_topics:Dictionary = {}

## contains all tags associated with all topics. When a tag is added to a
## topic, the tag is appended to this array
var all_tags:Array[String] = []

## contains all references of the objects with the topics they are subscribed
## to
var subscriptions: Dictionary = {}

## adds a new topic
func create_topic(topic:String, tags:Array[String]=[]) -> void:
	if topic not in all_topics:
		all_topics[topic] = {
			"posts":[]
		}
	create_tags(tags)


## creates a new tag or new tags
func create_tags(tags:Array[String]) -> void:
	for i in tags:
		if not i in all_tags:
			all_tags.append(i)


## if the tags in the array do not exist, the listener subscribes to the
## topic in general. If the topic doesn't exist, nothing happens
func subscribe(_listener:Object, _to_topic:String, _tags:Array[String]=[]) -> void:
	if not _listener.has_method(&"_handle_post"):
		return
	var listener_id:int = int(_listener.get_instance_id())
	# adds the _tags to `all_tags`
	create_tags(_tags)
	var _tag_ref:Array[String] = tag_ref(_tags)
	# handles how subscriptions are added
	if _to_topic not in all_topics:
		return
	if listener_id not in subscriptions:
		subscriptions[listener_id] = [{_to_topic:_tag_ref}]
	elif _to_topic not in subscriptions[listener_id]:
		subscriptions[listener_id].append({_to_topic:_tag_ref})
	else:
		for i in _tag_ref:
			if i not in subscriptions[listener_id][_to_topic]:
				subscriptions[listener_id][_to_topic].append(i)

## listeners unsubscribe from a topic and if _from_topic is
## omitted, then the listener is unsubscribed from all 
func unsubscribe(_listener:Object, _from_topic:String = "") -> void:
	var _listener_id:int = _listener.get_instance_id()
	if _listener_id in subscriptions:
		if _from_topic.is_empty():
			subscriptions.erase(_listener_id)
			return
		if _from_topic in subscriptions[_listener_id]:
			subscriptions[_listener_id].erase(_from_topic)

## publishes a post related to the topic given. Optional tags may be
## given to allow fine-tuned retrieval. The topic is created if it doesn't exist
func publish(post, topic:String, tags:Array[String]=[]) -> void:
	pass

## deletes a topic from the topic list. Make sure to remove all subscribers
## to this topic before deletion.
func delete_topic(_topic:String) -> void:
	if _topic in all_topics:
		all_topics.erase(_topic)

## deletes a tag from the tag list
func delete_tag(_tags:Array[String] = []) -> void:
	for tag in _tags:
		if tag in all_tags:
			all_tags.erase(tag)

## clears the array of tags that a subscriber uses to filter out their content
func clear_tags(_listener:Object) -> void:
	pass

## returns all topics as a list of strings
func get_topics() -> void:
	pass

## returns all tags as a list of strings
func get_tags() -> void:
	pass

## returns the list of subscribers to a particular topic
func get_subscribers(_topic:String) -> void:
	pass

## clears all the subscriptions, tags and topics
func clear_bulletin() -> void:
	subscriptions.clear()
	all_tags.clear()
	all_topics.clear()

func tag_ref(tags: Array[String]) -> Array[String]:
	var index_list:Array[int] = []
	var ref_list:Array[String] = []
	for i in tags:
		if i in all_tags:
			index_list.append(all_tags.find(i))
	for i in index_list:
		ref_list.append(all_tags[i])
	return ref_list
