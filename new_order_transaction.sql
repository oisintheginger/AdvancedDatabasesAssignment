set serveroutput on
alter session set current_schema=TPC_C;

DECLARE
warehouse_num NUMBER;
district_num NUMBER;
ol_cnt NUMBER;
curr_date CHAR(10);
customer_num NUMBER;
item_count NUMBER;
item_id NUMBER;
warehouse_tax NUMBER(4,4);
district_tax NUMBER(4,4);
district_next_order NUMBER;
customer_discount NUMBER(4,4);
customer_last VARCHAR2(16 BYTE);
customer_credit CHAR(2 BYTE);
item_price NUMBER(5,2);
item_name VARCHAR2(24 BYTE);
item_data VARCHAR2(50 BYTE);
stock_quantity NUMBER;
stock_dist CHAR(24 BYTE);
stock_data VARCHAR2(50 BYTE);
stock_order_count NUMBER(4,0);
stock_year_to_date NUMBER(8,0);
order_line_number NUMBER;

loop_count NUMBER := 1000;

BEGIN
warehouse_num := 1;
curr_date := TO_CHAR(SYSDATE,'YYYY-MM-DD');
FOR counter IN 1..loop_count
LOOP
    district_num := TRUNC(dbms_random.value(1,10),0);
    ol_cnt := TRUNC(dbms_random.value(1,11),0);
    SELECT C_ID INTO customer_num FROM TPC_C.customer WHERE C_D_ID = district_num AND C_W_ID = warehouse_num AND ROWNUM <= 1;
    SELECT COUNT(I_ID) INTO item_count FROM TPC_C.item;
    item_id := TRUNC(dbms_random.value(0,item_count),0);
    SELECT W_TAX INTO warehouse_tax FROM TPC_C.warehouse WHERE W_ID = warehouse_num;
    SELECT D_TAX, D_NEXT_O_ID INTO district_tax, district_next_order FROM TPC_C.district WHERE D_W_ID = warehouse_num AND D_ID = district_num;
    SELECT C_DISCOUNT, C_LAST, C_CREDIT INTO customer_discount, customer_last, customer_credit FROM TPC_C.customer WHERE C_W_ID = warehouse_num AND C_D_ID = district_num AND C_ID = customer_num;
    UPDATE district SET D_NEXT_O_ID = district_next_order + 1 WHERE D_W_ID = warehouse_num AND D_ID = district_num;
    INSERT INTO orders (O_ID, O_W_ID, O_D_ID, O_C_ID, O_CARRIER_ID, O_OL_CNT, O_ALL_LOCAL, O_ENTRY_D) VALUES (district_next_order, warehouse_num, district_num, customer_num, NULL, ol_cnt, 1, TO_DATE(curr_date, 'YYYY-MM-DD'));
    INSERT INTO new_order(NO_W_ID, NO_D_ID, NO_O_ID) VALUES (warehouse_num, district_num,district_next_order);
    SELECT I_PRICE, I_NAME, I_DATA INTO item_price, item_name, item_data FROM TPC_C.item WHERE I_ID = item_id;
    CASE district_num
    WHEN 1 THEN 
        SELECT S_QUANTITY, S_DIST_01, S_DATA, S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 2 THEN
        SELECT S_QUANTITY, S_DIST_02, S_DATA, S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 3 THEN
        SELECT S_QUANTITY, S_DIST_03, S_DATA, S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 4 THEN
        SELECT S_QUANTITY, S_DIST_04, S_DATA, S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 5 THEN
        SELECT S_QUANTITY, S_DIST_05, S_DATA, S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 6 THEN
        SELECT S_QUANTITY, S_DIST_06, S_DATA , S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 7 THEN
        SELECT S_QUANTITY, S_DIST_07, S_DATA , S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 8 THEN
        SELECT S_QUANTITY, S_DIST_08, S_DATA , S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    WHEN 9 THEN
        SELECT S_QUANTITY, S_DIST_09, S_DATA , S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    ELSE
        SELECT S_QUANTITY, S_DIST_10, S_DATA , S_ORDER_CNT, S_YTD INTO stock_quantity, stock_dist, stock_data, stock_order_count, stock_year_to_date FROM TPC_C.stock WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    END CASE;
    IF stock_quantity > (ol_cnt + 10) THEN
    UPDATE TPC_C.stock SET S_QUANTITY = stock_quantity - ol_cnt, S_YTD = ol_cnt + stock_year_to_date, S_ORDER_CNT = stock_order_count + 1 WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    ELSE
    UPDATE TPC_C.stock SET S_QUANTITY = (stock_quantity - ol_cnt) + 91, S_YTD = ol_cnt + stock_year_to_date, S_ORDER_CNT = stock_order_count + 1 WHERE S_I_ID = item_id AND S_W_ID = warehouse_num;
    END IF;
    SELECT COALESCE(MAX(OL_NUMBER),1) INTO order_line_number FROM TPC_C.order_line WHERE OL_W_ID = warehouse_num AND OL_D_ID = district_num AND OL_O_ID = district_next_order;
    INSERT INTO TPC_C.order_line (OL_O_ID, OL_D_ID, OL_W_ID, OL_NUMBER, OL_I_ID, OL_DELIVER_D, OL_AMOUNT, OL_SUPPLY_W_ID, OL_QUANTITY, OL_DIST_INFO) VALUES (district_next_order,district_num,warehouse_num,order_line_number,item_id,NULL,ol_cnt*item_price,warehouse_num,ol_cnt,'stock_data');
END LOOP;
END;