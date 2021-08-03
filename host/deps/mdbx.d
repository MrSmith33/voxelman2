module deps.mdbx;
extern(C):
void mdbx_build();
void mdbx_canary_get();
void mdbx_canary_put();
void mdbx_cmp();
void mdbx_cursor_bind();
void mdbx_cursor_close();
void mdbx_cursor_copy();
void mdbx_cursor_count();
void mdbx_cursor_create();
void mdbx_cursor_dbi();
void mdbx_cursor_del();
void mdbx_cursor_eof();
void mdbx_cursor_get();
void mdbx_cursor_get_userctx();
void mdbx_cursor_on_first();
void mdbx_cursor_on_last();
void mdbx_cursor_open();
void mdbx_cursor_put();
void mdbx_cursor_renew();
void mdbx_cursor_set_userctx();
void mdbx_cursor_txn();
void mdbx_dbi_close();
void mdbx_dbi_dupsort_depthmask();
void mdbx_dbi_flags();
void mdbx_dbi_flags_ex();
void mdbx_dbi_open();
void mdbx_dbi_open_ex();
void mdbx_dbi_sequence();
void mdbx_dbi_stat();
void mdbx_dcmp();
void mdbx_default_pagesize();
void mdbx_del();
void mdbx_double_from_key();
void mdbx_drop();
void mdbx_dump_val();
void mdbx_env_close();
void mdbx_env_close_ex();
void mdbx_env_copy();
void mdbx_env_copy2fd();
void mdbx_env_create();
void mdbx_env_delete();
void mdbx_env_get_fd();
void mdbx_env_get_flags();
void mdbx_env_get_hsr();
void mdbx_env_get_maxdbs();
void mdbx_env_get_maxkeysize();
void mdbx_env_get_maxkeysize_ex();
void mdbx_env_get_maxreaders();
void mdbx_env_get_maxvalsize_ex();
void mdbx_env_get_option();
void mdbx_env_get_path();
void mdbx_env_get_userctx();
void mdbx_env_info();
void mdbx_env_info_ex();
void mdbx_env_open();
void mdbx_env_open_for_recovery();
void mdbx_env_pgwalk();
void mdbx_env_set_assert();
void mdbx_env_set_flags();
void mdbx_env_set_geometry();
void mdbx_env_set_hsr();
void mdbx_env_set_mapsize();
void mdbx_env_set_maxdbs();
void mdbx_env_set_maxreaders();
void mdbx_env_set_option();
void mdbx_env_set_syncbytes();
void mdbx_env_set_syncperiod();
void mdbx_env_set_userctx();
void mdbx_env_stat();
void mdbx_env_stat_ex();
void mdbx_env_sync();
void mdbx_env_sync_ex();
void mdbx_env_sync_poll();
void mdbx_env_turn_for_recovery();
void mdbx_estimate_distance();
void mdbx_estimate_move();
void mdbx_estimate_range();
void mdbx_float_from_key();
void mdbx_get();
void mdbx_get_datacmp();
void mdbx_get_equal_or_great();
void mdbx_get_ex();
void mdbx_get_keycmp();
void mdbx_int32_from_key();
void mdbx_int64_from_key();
void mdbx_is_dirty();
void mdbx_is_readahead_reasonable();
void mdbx_jsonInteger_from_key();
void mdbx_key_from_double();
void mdbx_key_from_float();
void mdbx_key_from_int32();
void mdbx_key_from_int64();
void mdbx_key_from_jsonInteger();
void mdbx_key_from_ptrdouble();
void mdbx_key_from_ptrfloat();
void mdbx_liberr2str();
void mdbx_limits_dbsize_max();
void mdbx_limits_dbsize_min();
void mdbx_limits_keysize_max();
void mdbx_limits_pgsize_max();
void mdbx_limits_pgsize_min();
void mdbx_limits_txnsize_max();
void mdbx_limits_valsize_max();
void mdbx_panic();
void mdbx_put();
void mdbx_reader_check();
void mdbx_reader_list();
void mdbx_replace();
void mdbx_replace_ex();
void mdbx_setup_debug();
void mdbx_strerror();
void mdbx_thread_register();
void mdbx_thread_unregister();
void mdbx_txn_abort();
void mdbx_txn_begin();
void mdbx_txn_begin_ex();
void mdbx_txn_break();
void mdbx_txn_commit();
void mdbx_txn_commit_ex();
void mdbx_txn_env();
void mdbx_txn_flags();
void mdbx_txn_get_userctx();
void mdbx_txn_id();
void mdbx_txn_info();
void mdbx_txn_lock();
void mdbx_txn_renew();
void mdbx_txn_reset();
void mdbx_txn_set_userctx();
void mdbx_txn_straggler();
void mdbx_txn_unlock();
void mdbx_version();
