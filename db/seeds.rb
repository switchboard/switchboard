
# create initial message states
MessageState.find_or_create_by_name('outgoing');
MessageState.find_or_create_by_name('incoming');
MessageState.find_or_create_by_name('handled');
MessageState.find_or_create_by_name('sent');
MessageState.find_or_create_by_name('error_incoming');
MessageState.find_or_create_by_name('error_outgoing');
