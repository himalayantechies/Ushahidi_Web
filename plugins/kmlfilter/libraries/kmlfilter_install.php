<?php defined('SYSPATH') or die('No direct script access.');


class Kmlfilter_Install {

	public function __construct() {
		$this->db = Database::instance();
		$this->placemark_table = Kohana::config('database.default.table_prefix')."placemark";
	}

	public function run_install() {
		$this->db->query('DROP FUNCTION IF EXISTS `myWithin`;');
		$this->db->query('
			CREATE TABLE IF NOT EXISTS `'.$this->placemark_table.'` (
				`id` int(11) NOT NULL,
				`layer_id` int(11) NOT NULL,
				`placemark` varchar(255) DEFAULT NULL,
				`coord` longtext
			) ENGINE=InnoDB DEFAULT CHARSET=utf8;
			ALTER TABLE `'.$this->placemark_table.'`
				 MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
			ALTER TABLE `'.$this->placemark_table.'`
				ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `layer_placemark_id` (`layer_id`,`placemark`);'
  		);
		$this->db->query('
			CREATE FUNCTION myWithin(p POINT, poly POLYGON) RETURNS INT(1) DETERMINISTIC
			BEGIN
			DECLARE n INT DEFAULT 0;
			DECLARE pX DECIMAL(9,6);
			DECLARE pY DECIMAL(9,6);
			DECLARE ls LINESTRING;
			DECLARE poly1 POINT;
			DECLARE poly1X DECIMAL(9,6);
			DECLARE poly1Y DECIMAL(9,6);
			DECLARE poly2 POINT;
			DECLARE poly2X DECIMAL(9,6);
			DECLARE poly2Y DECIMAL(9,6);
			DECLARE i INT DEFAULT 0;
			DECLARE result INT(1) DEFAULT 0;
			SET pX = X(p);
			SET pY = Y(p);
			SET ls = ExteriorRing(poly);
			SET poly2 = EndPoint(ls);
			SET poly2X = X(poly2);
			SET poly2Y = Y(poly2);
			SET n = NumPoints(ls);
			WHILE i<n DO
			SET poly1 = PointN(ls, (i+1));
			SET poly1X = X(poly1);
			SET poly1Y = Y(poly1);
			IF ( ( ( ( poly1X <= pX ) && ( pX < poly2X ) ) || ( ( poly2X <= pX ) && ( pX < poly1X ) ) ) && ( pY > ( poly2Y - poly1Y ) * ( pX - poly1X ) / ( poly2X - poly1X ) + poly1Y ) ) THEN
			SET result = !result;
			END IF;
			SET poly2X = poly1X;
			SET poly2Y = poly1Y;
			SET i = i + 1;
			END WHILE;
			RETURN result;
			END;
			');
			$db->query('
				CREATE view vw_placemark AS 
				SELECT l.id AS location_id, p.id AS placemark_id, CONCAT(p.layer_id, "_", p.placemark) AS lkey 
				FROM location l, placemark p 
				WHERE myWithin(PointFromText(CONCAT( "POINT(", l.latitude, " ", l.longitude, ")" )), PolyFromText(CONCAT("POLYGON((", p.coord, "))")))
			');
	}
	
	/**
	 * Function: uninstall
	 *
	 */
	public function uninstall() {
		$this->db->query('DROP FUNCTION IF EXISTS `myWithin`;');
	
	}
}