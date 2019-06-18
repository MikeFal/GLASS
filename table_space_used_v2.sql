with tablesize(tablename,row_count,reserved_pages,used_pages,data_pages)
as
(SELECT
	t.name
	,SUM(CASE
		WHEN (ps.index_id < 2) THEN ps.row_count
		ELSE 0
	 END)
	,sum(reserved_page_count)
	,sum(used_page_count)
	,sum( CASE
	WHEN ps.index_id < 2 THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
	ELSE lob_used_page_count + row_overflow_used_page_count
	END)
from
	sys.tables t
	join sys.partitions p on (t.object_id = p.object_id) 
	join sys.dm_db_partition_stats ps on (p.partition_id = ps.partition_id and p.index_id = ps.index_id)
group by t.name)
select
	tablename
	,row_count
	,reserved_pages*8 reserved_kb
	,data_pages * 8 data_kb
	,case when used_pages>data_pages then used_pages-data_pages else 0 end * 8 index_kb
	,case when reserved_pages>used_pages then reserved_pages-used_pages else 0 end * 8 free_kb
from 
	tablesize
order by reserved_pages desc
