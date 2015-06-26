import java.util.Vector;
import java.util.Arrays;

public class GestureRecognizer {
	private static final double INFINITY = Double.POSITIVE_INFINITY;
	private static final int RESAMPLE_POINT_COUNT = 64;
	private static final int  SCALE_SIZE = 250;
	private static final double PARAM_PHI =  0.618034;
	private static final double HALF_DIAGONAL = 176.776695;
	private static final double THETA_A = -0.78539815;
	private static final double  THETA_B = 0.78539815;
	private static final double THETA_C = 0.0349065844444444;
	private Vector<MatchingTemplate> mTemplates = new Vector<MatchingTemplate>();

	public GestureRecognizer() {
		initTemplates();
	}

	private Vector<CCPoint> resamplePoints(Vector<CCPoint> points, int spacedPointsNum) {
		double spacedParamI = getPathLength(points) / (spacedPointsNum-1);
		double totalDistance = 0;

		Vector<CCPoint> newPoints = new Vector<CCPoint>();
		if (points.size() == 0) return newPoints;

		newPoints.add(points.get(0));

		for(int i=1; i<points.size(); i++) {
			double dist = getDistance(points.get(i-1), points.get(i));
			if(totalDistance + dist >= spacedParamI) {
				double scale = (spacedParamI - totalDistance) / dist;
				double qx = points.get(i-1).x + scale * (points.get(i).x - points.get(i-1).x);
				double qy = points.get(i-1).y + scale * (points.get(i).y - points.get(i-1).y);
				CCPoint qPnt = new CCPoint(qx, qy);
				newPoints.add(qPnt);
				points.add(i, qPnt);
				totalDistance = 0;
			}
			else {
				totalDistance += dist;
			}
		}
		return newPoints;
	}

	private double getPathLength(Vector<CCPoint> points){
		double dist = 0;
		for(int i=1; i < points.size(); i++) 
			dist += getDistance(points.get(i), points.get(i-1));
		return dist;
	}


	private double getDistance(CCPoint pnt1, CCPoint pnt2) {
		double dx = pnt1.x - pnt2.x;
		double dy = pnt1.y - pnt2.y;
		return sqrt((float)(dx * dx + dy * dy));
	}

	private double getInadicativeAngle(Vector<CCPoint> points) {
		CCPoint centroid = getCentroid(points);
		return atan2((float)(centroid.y - points.get(0).y), (float)(centroid.x - points.get(0).x));
	}

	private CCPoint getCentroid(Vector<CCPoint> points) {
		double cx = 0;
		double cy = 0;
		int size = points.size();
		for(int i = 0; i<size; i++) {
			cx += points.get(i).x / size; 
			cx += points.get(i).y / size; 
		}
		return new CCPoint(cx, cy);
	}

	private Vector<CCPoint> rotatePointsBy(Vector<CCPoint> points, double w) {
		Vector<CCPoint> newPoints = new Vector<CCPoint>();
		CCPoint centroid = getCentroid(points);
		double cosw = cos((float)w);
		double sinw = sin((float)w);
		for(int i=0; i<points.size(); i++) {
			double qx = (points.get(i).x - centroid.x) * cosw - (points.get(i).y - centroid.y) * sinw + centroid.x;
			double qy = (points.get(i).x - centroid.x) * sinw + (points.get(i).y - centroid.y) * cosw + centroid.y;
			newPoints.add(new CCPoint(qx, qy));
		}
		return newPoints;
	}

	private Vector<CCPoint> scalePointsTo(Vector<CCPoint> points, double scaleSize) {
		double bboxMinX = INFINITY;
		double bboxMinY = INFINITY; 
		double bboxMaxX = -INFINITY;
		double bboxMaxY = -INFINITY;

		for(int i=0; i<points.size(); i++) {
			if(points.get(i).x < bboxMinX)
				bboxMinX = points.get(i).x;
			if(points.get(i).y < bboxMinY)
				bboxMinY = points.get(i).y;
			if(points.get(i).x > bboxMaxX)
				bboxMaxX = points.get(i).x;
			if(points.get(i).y > bboxMaxY)
				bboxMaxY = points.get(i).y;
		}

		double bWidth = bboxMaxX - bboxMinX;
		double bHeight = bboxMaxY - bboxMinY;
		
		Vector<CCPoint> newPoints = new Vector<CCPoint>();

		for(int i=0; i<points.size(); i++) {
			double qx = points.get(i).x * scaleSize / bWidth;
			double qy = points.get(i).y * scaleSize / bHeight;
			newPoints.add(new CCPoint(qx, qy));
		}
		return newPoints;
	}

	private Vector<CCPoint> translatePointsTo(Vector<CCPoint> points, CCPoint kPoint) {
		CCPoint centroid = getCentroid(points);

		Vector<CCPoint> newPoints = new Vector<CCPoint>();

		for(int i=0; i<points.size(); i++) {
			double qx = points.get(i).x + kPoint.x - centroid.x;
			double qy = points.get(i).y + kPoint.y - centroid.y;
			newPoints.add(new CCPoint(qx, qy));
		}
		return newPoints;
	}

	private MatchingResult doRecognize(Vector<CCPoint> points, Vector<MatchingTemplate> templates) {
		double b = INFINITY;
		int bestTemplateIndex = -1;

		for(int i=0; i<templates.size(); i++) {
			double d = getDistAtBestAngle(points, templates.get(i), THETA_A, THETA_B, THETA_C);
			if(d < b) {
				b = d;
				bestTemplateIndex = i;
			}
		}
		double score = 1 - b / HALF_DIAGONAL;
		return new MatchingResult(templates.get(bestTemplateIndex).templateName, score);
	}

	private double getDistAtBestAngle(Vector<CCPoint> points, MatchingTemplate t, double theta1, double theta2, double theta3) {
		double x1 = PARAM_PHI * theta1 + (1 - PARAM_PHI) * theta2;
		double f1 = getDistAtAngle(points, t, x1);
		double x2 = (1 - PARAM_PHI) * theta1 + PARAM_PHI * theta2;
		double f2 = getDistAtAngle(points, t, x2);
		while(abs((float)(theta2 - theta1)) > theta3) {
			if(f1 < f2) {
				theta2 = x2;
				x2 = x1;
				f2 = f1;
				x1 = PARAM_PHI * theta1 + (1 - PARAM_PHI) * theta2;
				f1 = getDistAtAngle(points, t, x1);
			}
			else {
				theta1 = x1;
				x1 = x2;
				f1 = f2;
				x2 = (1 - PARAM_PHI) * theta1 + PARAM_PHI * theta2;
				f2 = getDistAtAngle(points, t, x2);
			}
		}
		return f1 < f2 ? f1 : f2;
	}

	private double getDistAtAngle(Vector<CCPoint> points, MatchingTemplate t, double theta) {
		Vector<CCPoint> newPoints = rotatePointsBy(points, theta);
		double dist = getPathDist(newPoints, t.samples);
		return dist;
	}

	private double getPathDist(Vector<CCPoint> pointsA, Vector<CCPoint> pointsB){
		double dist = 0;
		int limit = min(pointsA.size(), pointsB.size());
		for(int i=0; i<limit ; i++) 
			dist += getDistance(pointsA.get(i), pointsB.get(i));
		return dist / limit;
	}

	private void generateIntoTemplate(String name, Vector<CCPoint> points) {
		points = resamplePoints(points, RESAMPLE_POINT_COUNT);
		if (points.size() == 0)
			return;
		points = rotatePointsBy(points, -getInadicativeAngle(points));
		points = scalePointsTo(points, SCALE_SIZE);
		points = translatePointsTo(points, new CCPoint(0, 0));

		mTemplates.add(new MatchingTemplate(name, points));
	}

	private MatchingResult checkMatchingGesture(Vector<CCPoint> points) {
		points = resamplePoints(points, RESAMPLE_POINT_COUNT);
		if (points.size() == 0)
			return new MatchingResult("No Gesture", 0.0);
		points = rotatePointsBy(points, -getInadicativeAngle(points));
		points = scalePointsTo(points, SCALE_SIZE);
		points = translatePointsTo(points, new CCPoint(0, 0));
		return doRecognize(points, mTemplates);
	}

	private void initTemplates() {
		/** For test only */
		CCPoint[] rectPoints = {new CCPoint(286.336243, 497.743988), new CCPoint(286.336243, 489.771454), new CCPoint(286.336243, 483.825806), new CCPoint(286.336243, 467.813141), new CCPoint(286.336243, 457.813660), new CCPoint(286.336243, 445.854828), new CCPoint(286.336243, 425.855896), new CCPoint(286.336243, 413.897064), new CCPoint(288.363159, 387.952484), new CCPoint(292.416992, 359.980988), new CCPoint(296.335724, 332.009491), new CCPoint(296.335724, 320.050659), new CCPoint(296.335724, 308.091858), new CCPoint(296.335724, 302.078644), new CCPoint(296.335724, 292.079163), new CCPoint(296.335724, 286.133545), new CCPoint(296.335724, 274.107147), new CCPoint(296.335724, 268.161530), new CCPoint(296.335724, 262.148315), new CCPoint(296.335724, 260.121399), new CCPoint(296.335724, 258.162048), new CCPoint(296.335724, 256.135132), new CCPoint(296.335724, 254.175766), new CCPoint(296.335724, 252.148849), new CCPoint(302.416473, 252.148849), new CCPoint(306.335175, 252.148849), new CCPoint(322.415405, 256.135132), new CCPoint(364.305084, 256.135132), new CCPoint(380.250183, 254.175766), new CCPoint(420.248077, 246.135651), new CCPoint(436.193176, 236.203751), new CCPoint(470.110321, 228.163635), new CCPoint(486.190552, 228.163635), new CCPoint(492.136169, 228.163635), new CCPoint(498.081818, 228.163635), new CCPoint(504.162567, 228.163635), new CCPoint(510.108215, 228.163635), new CCPoint(516.053833, 228.163635), new CCPoint(522.134583, 228.163635), new CCPoint(528.080261, 228.163635), new CCPoint(534.025879, 228.163635), new CCPoint(544.025330, 228.163635), new CCPoint(556.051758, 228.163635), new CCPoint(561.997375, 228.163635), new CCPoint(569.969910, 228.163635), new CCPoint(571.996826, 228.163635), new CCPoint(577.942444, 228.163635), new CCPoint(584.023254, 228.163635), new CCPoint(585.915039, 228.163635), new CCPoint(587.941956, 228.163635), new CCPoint(587.941956, 234.176834), new CCPoint(587.941956, 240.190018), new CCPoint(587.941956, 246.135651), new CCPoint(587.941956, 256.135132), new CCPoint(587.941956, 268.161530), new CCPoint(587.941956, 274.107147), new CCPoint(587.941956, 284.106628), new CCPoint(587.941956, 294.106110), new CCPoint(587.941956, 310.051208), new CCPoint(587.941956, 322.077606), new CCPoint(587.941956, 332.009491), new CCPoint(587.941956, 342.008972), new CCPoint(591.995789, 353.967804), new CCPoint(593.887573, 371.939819), new CCPoint(597.941406, 403.897614), new CCPoint(597.941406, 419.910278), new CCPoint(597.941406, 431.869080), new CCPoint(597.941406, 437.882294), new CCPoint(597.941406, 443.827911), new CCPoint(597.941406, 449.841125), new CCPoint(597.941406, 455.854309), new CCPoint(597.941406, 461.799957), new CCPoint(597.941406, 467.813141), new CCPoint(597.941406, 473.826324), new CCPoint(597.941406, 479.771973), new CCPoint(597.941406, 485.785156), new CCPoint(597.941406, 491.798370), new CCPoint(597.941406, 493.757721), new CCPoint(597.941406, 499.770905), new CCPoint(597.941406, 501.797821), new CCPoint(597.941406, 507.743469), new CCPoint(597.941406, 509.770386), new CCPoint(597.941406, 511.729736), new CCPoint(597.941406, 513.756653), new CCPoint(597.941406, 519.702271), new CCPoint(597.941406, 525.715515), new CCPoint(597.941406, 527.742432), new CCPoint(595.914490, 527.742432), new CCPoint(583.888123, 521.729187), new CCPoint(577.942444, 517.742920), new CCPoint(549.970947, 509.770386), new CCPoint(486.055420, 501.797821), new CCPoint(452.138306, 501.797821), new CCPoint(442.138824, 501.797821), new CCPoint(432.139343, 501.797821), new CCPoint(426.193726, 501.797821), new CCPoint(416.194244, 501.797821), new CCPoint(410.113495, 501.797821), new CCPoint(388.222748, 501.797821), new CCPoint(372.277649, 501.797821), new CCPoint(362.278168, 501.797821), new CCPoint(350.251770, 501.797821), new CCPoint(344.306152, 501.797821), new CCPoint(338.225403, 501.797821), new CCPoint(336.333588, 501.797821), new CCPoint(330.252838, 501.797821), new CCPoint(324.307190, 501.797821), new CCPoint(318.361572, 499.770905), new CCPoint(310.253906, 499.770905), new CCPoint(308.362091, 499.770905), new CCPoint(308.362091, 499.770905)};
		CCPoint[] circlePoints = {new CCPoint(406.194763, 174.247559), new CCPoint(404.302979, 174.247559), new CCPoint(402.276062, 174.247559), new CCPoint(400.249146, 174.247559), new CCPoint(398.222229, 174.247559), new CCPoint(396.330444, 174.247559), new CCPoint(394.303497, 174.247559), new CCPoint(392.276581, 174.247559), new CCPoint(390.249664, 174.247559), new CCPoint(388.222748, 174.247559), new CCPoint(384.304047, 174.247559), new CCPoint(382.277130, 174.247559), new CCPoint(378.223267, 174.247559), new CCPoint(372.277649, 174.247559), new CCPoint(364.305084, 174.247559), new CCPoint(358.359467, 174.247559), new CCPoint(352.278687, 174.247559), new CCPoint(352.278687, 176.274475), new CCPoint(346.333069, 176.274475), new CCPoint(340.387451, 176.274475), new CCPoint(338.360504, 178.301392), new CCPoint(332.414886, 180.260757), new CCPoint(330.387970, 180.260757), new CCPoint(326.334137, 182.287674), new CCPoint(320.388489, 186.273956), new CCPoint(318.361572, 188.233307), new CCPoint(316.334656, 188.233307), new CCPoint(310.389008, 192.219589), new CCPoint(308.362091, 194.246506), new CCPoint(302.416473, 200.259705), new CCPoint(292.416992, 210.191605), new CCPoint(290.390076, 212.218521), new CCPoint(290.390076, 214.245453), new CCPoint(286.471375, 220.191086), new CCPoint(284.444458, 222.218002), new CCPoint(280.390594, 228.163635), new CCPoint(274.444977, 242.149384), new CCPoint(272.418060, 250.189499), new CCPoint(270.391144, 252.148849), new CCPoint(268.364227, 252.148849), new CCPoint(268.364227, 254.175766), new CCPoint(266.472412, 256.135132), new CCPoint(266.472412, 258.162048), new CCPoint(264.445496, 262.148315), new CCPoint(264.445496, 268.161530), new CCPoint(264.445496, 272.147797), new CCPoint(262.418579, 276.134064), new CCPoint(262.418579, 284.106628), new CCPoint(262.418579, 290.119812), new CCPoint(262.418579, 296.065460), new CCPoint(258.364746, 302.078644), new CCPoint(258.364746, 308.091858), new CCPoint(258.364746, 314.037476), new CCPoint(258.364746, 320.050659), new CCPoint(258.364746, 326.063873), new CCPoint(258.364746, 332.009491), new CCPoint(258.364746, 342.008972), new CCPoint(258.364746, 348.022156), new CCPoint(258.364746, 353.967804), new CCPoint(258.364746, 359.980988), new CCPoint(258.364746, 369.980469), new CCPoint(258.364746, 379.979950), new CCPoint(258.364746, 391.938782), new CCPoint(258.364746, 397.951965), new CCPoint(258.364746, 407.883881), new CCPoint(258.364746, 417.883331), new CCPoint(258.364746, 423.896545), new CCPoint(258.364746, 433.896027), new CCPoint(258.364746, 435.855377), new CCPoint(258.364746, 439.841644), new CCPoint(258.364746, 441.868561), new CCPoint(258.364746, 447.881775), new CCPoint(260.391663, 447.881775), new CCPoint(260.391663, 453.827393), new CCPoint(260.391663, 459.840576), new CCPoint(262.418579, 465.853790), new CCPoint(264.445496, 467.813141), new CCPoint(268.364227, 473.826324), new CCPoint(268.364227, 475.785706), new CCPoint(270.391144, 479.771973), new CCPoint(272.418060, 481.798889), new CCPoint(282.282410, 489.771454), new CCPoint(288.363159, 497.743988), new CCPoint(292.281860, 503.757202), new CCPoint(298.362640, 513.756653), new CCPoint(304.308258, 515.716003), new CCPoint(306.335175, 517.742920), new CCPoint(308.362091, 517.742920), new CCPoint(314.307739, 519.702271), new CCPoint(322.280273, 523.756165), new CCPoint(326.334137, 525.715515), new CCPoint(340.252319, 531.728699), new CCPoint(344.306152, 531.728699), new CCPoint(346.197937, 533.688049), new CCPoint(348.224854, 533.688049), new CCPoint(350.251770, 533.688049), new CCPoint(350.251770, 535.714966), new CCPoint(356.197418, 535.714966), new CCPoint(362.278168, 537.674316), new CCPoint(374.169434, 537.674316), new CCPoint(380.250183, 537.674316), new CCPoint(386.195831, 537.674316), new CCPoint(392.141449, 537.674316), new CCPoint(398.222229, 537.674316), new CCPoint(408.221680, 537.674316), new CCPoint(418.086029, 537.674316), new CCPoint(434.166260, 537.674316), new CCPoint(450.111389, 537.674316), new CCPoint(462.137756, 537.674316), new CCPoint(478.082886, 541.728149), new CCPoint(488.082336, 541.728149), new CCPoint(499.973602, 539.701233), new CCPoint(502.000519, 539.701233), new CCPoint(504.027435, 539.701233), new CCPoint(504.027435, 537.674316), new CCPoint(509.973083, 535.714966), new CCPoint(516.053833, 531.728699), new CCPoint(534.025879, 523.756165), new CCPoint(539.971497, 521.729187), new CCPoint(557.943542, 509.770386), new CCPoint(569.969910, 495.784637), new CCPoint(575.915527, 489.771454), new CCPoint(579.969360, 481.798889), new CCPoint(587.941956, 469.840057), new CCPoint(591.860657, 461.799957), new CCPoint(597.941406, 455.854309), new CCPoint(601.860107, 449.841125), new CCPoint(601.860107, 447.881775), new CCPoint(605.913940, 441.868561), new CCPoint(605.913940, 439.841644), new CCPoint(605.913940, 437.882294), new CCPoint(605.913940, 433.896027), new CCPoint(605.913940, 431.869080), new CCPoint(605.913940, 429.909729), new CCPoint(605.913940, 423.896545), new CCPoint(605.913940, 421.869629), new CCPoint(605.913940, 417.883331), new CCPoint(605.913940, 411.937714), new CCPoint(605.913940, 409.910797), new CCPoint(605.913940, 405.924530), new CCPoint(605.913940, 399.911316), new CCPoint(605.913940, 391.938782), new CCPoint(605.913940, 385.925568), new CCPoint(603.887024, 385.925568), new CCPoint(603.887024, 379.979950), new CCPoint(599.968323, 373.966736), new CCPoint(599.968323, 371.939819), new CCPoint(599.968323, 367.953552), new CCPoint(599.968323, 362.007904), new CCPoint(593.887573, 353.967804), new CCPoint(593.887573, 348.022156), new CCPoint(589.968872, 342.008972), new CCPoint(585.915039, 330.050140), new CCPoint(585.915039, 324.036957), new CCPoint(584.023254, 318.023743), new CCPoint(579.969360, 306.064911), new CCPoint(575.915527, 298.092377), new CCPoint(574.023743, 296.065460), new CCPoint(569.969910, 290.119812), new CCPoint(564.024292, 288.092896), new CCPoint(564.024292, 282.079712), new CCPoint(557.943542, 278.093414), new CCPoint(554.024780, 272.147797), new CCPoint(539.971497, 264.107666), new CCPoint(536.052795, 258.162048), new CCPoint(534.025879, 258.162048), new CCPoint(528.080261, 254.175766), new CCPoint(526.053284, 254.175766), new CCPoint(522.134583, 250.189499), new CCPoint(514.026917, 248.162582), new CCPoint(514.026917, 246.135651), new CCPoint(512.135132, 246.135651), new CCPoint(512.135132, 244.176300), new CCPoint(506.054382, 242.149384), new CCPoint(504.027435, 242.149384), new CCPoint(500.108734, 242.149384), new CCPoint(498.081818, 240.190018), new CCPoint(496.054901, 238.163101), new CCPoint(490.109253, 234.176834), new CCPoint(488.082336, 234.176834), new CCPoint(486.055420, 234.176834), new CCPoint(480.109802, 234.176834), new CCPoint(478.082886, 232.217468), new CCPoint(476.191071, 232.217468), new CCPoint(474.164154, 230.190552), new CCPoint(468.083405, 230.190552), new CCPoint(466.191620, 230.190552), new CCPoint(460.110840, 230.190552), new CCPoint(460.110840, 228.163635), new CCPoint(458.219055, 228.163635), new CCPoint(456.192139, 228.163635), new CCPoint(456.192139, 226.204269), new CCPoint(454.165222, 226.204269), new CCPoint(452.138306, 226.204269), new CCPoint(452.138306, 224.177353), new CCPoint(450.111389, 224.177353), new CCPoint(450.111389, 222.218002), new CCPoint(448.219574, 222.218002), new CCPoint(446.192657, 222.218002), new CCPoint(444.165741, 220.191086), new CCPoint(442.138824, 220.191086), new CCPoint(442.138824, 218.231720), new CCPoint(440.247040, 218.231720), new CCPoint(438.220123, 218.231720), new CCPoint(436.193176, 218.231720), new CCPoint(436.193176, 218.231720)};
		CCPoint[] triPoints = {new CCPoint(450.111389, 505.784119), new CCPoint(448.084442, 503.757202), new CCPoint(442.138824, 495.784637), new CCPoint(428.085510, 485.785156), new CCPoint(408.221680, 459.840576), new CCPoint(392.141449, 445.854828), new CCPoint(386.195831, 441.868561), new CCPoint(376.196350, 427.882813), new CCPoint(368.223816, 421.869629), new CCPoint(362.278168, 413.897064), new CCPoint(360.251251, 413.897064), new CCPoint(350.251770, 407.883881), new CCPoint(336.333588, 391.938782), new CCPoint(324.307190, 373.966736), new CCPoint(312.280823, 365.994202), new CCPoint(292.416992, 345.995239), new CCPoint(268.364227, 326.063873), new CCPoint(256.472961, 314.037476), new CCPoint(226.474533, 296.065460), new CCPoint(212.556351, 282.079712), new CCPoint(198.503036, 272.147797), new CCPoint(190.530487, 264.107666), new CCPoint(178.504089, 250.189499), new CCPoint(162.558990, 232.217468), new CCPoint(152.559509, 222.218002), new CCPoint(144.586960, 214.245453), new CCPoint(142.560043, 214.245453), new CCPoint(142.560043, 212.218521), new CCPoint(146.613876, 212.218521), new CCPoint(156.613358, 212.218521), new CCPoint(162.558990, 208.232254), new CCPoint(184.584854, 208.232254), new CCPoint(196.476120, 208.232254), new CCPoint(206.475586, 204.245972), new CCPoint(256.472961, 196.273422), new CCPoint(278.363678, 192.219589), new CCPoint(326.334137, 188.233307), new CCPoint(374.304565, 184.247025), new CCPoint(402.276062, 184.247025), new CCPoint(412.275543, 184.247025), new CCPoint(428.220642, 184.247025), new CCPoint(434.166260, 184.247025), new CCPoint(440.247040, 184.247025), new CCPoint(446.192657, 184.247025), new CCPoint(448.219574, 184.247025), new CCPoint(450.246490, 184.247025), new CCPoint(454.165222, 184.247025), new CCPoint(462.137756, 184.247025), new CCPoint(472.137238, 184.247025), new CCPoint(488.082336, 188.233307), new CCPoint(504.162567, 188.233307), new CCPoint(530.107178, 188.233307), new CCPoint(541.998413, 188.233307), new CCPoint(551.997864, 188.233307), new CCPoint(564.024292, 188.233307), new CCPoint(579.969360, 188.233307), new CCPoint(581.996277, 188.233307), new CCPoint(584.023254, 188.233307), new CCPoint(589.968872, 188.233307), new CCPoint(595.914490, 188.233307), new CCPoint(601.995239, 188.233307), new CCPoint(615.913452, 188.233307), new CCPoint(625.912903, 188.233307), new CCPoint(637.939270, 188.233307), new CCPoint(643.884949, 188.233307), new CCPoint(649.965698, 188.233307), new CCPoint(651.857483, 188.233307), new CCPoint(655.911316, 188.233307), new CCPoint(657.938232, 188.233307), new CCPoint(659.830017, 188.233307), new CCPoint(667.937744, 188.233307), new CCPoint(673.883362, 188.233307), new CCPoint(675.910278, 188.233307), new CCPoint(681.855896, 188.233307), new CCPoint(687.801514, 188.233307), new CCPoint(689.828430, 188.233307), new CCPoint(689.828430, 190.260223), new CCPoint(689.828430, 192.219589), new CCPoint(689.828430, 196.273422), new CCPoint(687.801514, 196.273422), new CCPoint(687.801514, 198.232773), new CCPoint(685.909729, 204.245972), new CCPoint(683.882813, 206.205338), new CCPoint(681.855896, 206.205338), new CCPoint(679.828979, 208.232254), new CCPoint(679.828979, 210.191605), new CCPoint(679.828979, 212.218521), new CCPoint(677.802063, 212.218521), new CCPoint(677.802063, 214.245453), new CCPoint(677.802063, 218.231720), new CCPoint(675.910278, 220.191086), new CCPoint(669.829529, 226.204269), new CCPoint(663.883850, 240.190018), new CCPoint(643.884949, 254.175766), new CCPoint(635.912354, 266.134613), new CCPoint(609.967773, 302.078644), new CCPoint(585.915039, 322.077606), new CCPoint(571.996826, 334.036407), new CCPoint(564.024292, 345.995239), new CCPoint(554.024780, 365.994202), new CCPoint(538.079712, 379.979950), new CCPoint(529.972046, 391.938782), new CCPoint(524.026367, 409.910797), new CCPoint(518.080750, 421.869629), new CCPoint(510.108215, 429.909729), new CCPoint(506.054382, 441.868561), new CCPoint(490.109253, 461.799957), new CCPoint(486.055420, 467.813141), new CCPoint(486.055420, 473.826324), new CCPoint(486.055420, 475.785706), new CCPoint(484.028503, 477.812622), new CCPoint(484.028503, 479.771973), new CCPoint(484.028503, 481.798889), new CCPoint(482.001587, 483.825806), new CCPoint(482.001587, 489.771454), new CCPoint(482.001587, 491.798370), new CCPoint(480.109802, 491.798370), new CCPoint(480.109802, 493.757721), new CCPoint(478.082886, 499.770905), new CCPoint(476.055939, 501.797821), new CCPoint(474.029022, 503.757202), new CCPoint(474.029022, 505.784119), new CCPoint(472.137238, 505.784119), new CCPoint(470.110321, 505.784119), new CCPoint(470.110321, 505.784119)};
		
		Vector<CCPoint> rectSamples = new Vector(Arrays.asList(rectPoints));
		Vector<CCPoint> circleSamples = new Vector(Arrays.asList(circlePoints));
		Vector<CCPoint> triSamples = new Vector(Arrays.asList(triPoints));

		generateIntoTemplate("Rectangle", rectSamples);
		generateIntoTemplate("Circle", circleSamples);
		generateIntoTemplate("Triangle", triSamples);
	}
}

class MatchingTemplate {
	public String templateName;
	public Vector<CCPoint> samples;

	public MatchingTemplate(String name, Vector<CCPoint> points) {
		templateName = name;
		samples = points;
	}
}

class MatchingResult {
	public String templateName;
	public double templateScore;

	public MatchingResult(String name, double score) {
		templateName = name;
		templateScore = score;
	}
}

class CCPoint {
	public double x;
	public double y;
	public CCPoint(double _x, double _y) {
		x = _x;
		y = _y;
	}
}