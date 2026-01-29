const { useRef, useState, useEffect, createRef } = React;
const menuColor = "#1d6d74";
const calcColor = "#dd6d74";
/*--------------------
Items
--------------------*/
const items = [
{
  name: "home",
  id:	"homeId",
  color: menuColor,
  href: "#"
},
{
  name: "voedingstrafo",
  id:	"powerTrafoId",
  color: calcColor,
  href: "#" 
},
{
  name: "uitgangstrafo",
  id:	"ouputTrafoId",
  color: calcColor,
  href: "#" 
},
{
  name: "smoorspoel",
  id:	"filterChokeId",
  color: calcColor,
  href: "#" 
},
{
  name: "wetenswaardigheden",
  id:	"miscId",
  color: menuColor,
  href: "#" 
},
{
  name: "diversen",
  id:	"diversId",
  color: menuColor,
  href: "#" 
},
{
  name: "winkelwagen",
  id:	"shoppingCartId",
  color: menuColor,
  href: "#" 
},
{
  name: "zoeken",
  id:	"searchId",
  color: menuColor,
  href: "#" 
}
];

/*--------------------
Menu
--------------------*/
const Menu = ({ items }) => {
  const $root = useRef();
  const $indicator1 = useRef();
  const $indicator2 = useRef();
  const $items = useRef(items.map(createRef));
  const [active, setActive] = useState(0);

  const animate = () => {
    const menuOffset = $root.current.getBoundingClientRect();
    const activeItem = $items.current[active].current;
    const { width, height, top, left } = activeItem.getBoundingClientRect();

    const settings = {
      x: left - menuOffset.x,
      y: top - menuOffset.y,
      width: width,
      height: height,
      backgroundColor: items[active].color,
      ease: 'elastic.out(.7, .7)',
      duration: .8 };


    gsap.to($indicator1.current, {
      ...settings });


    gsap.to($indicator2.current, {
      ...settings,
      duration: 1 });

  };

  useEffect(() => {
    animate();
    window.addEventListener('resize', animate);

    return () => {
      window.removeEventListener('resize', animate);
    };
  
}, [active]);

  return /*#__PURE__*/(
    React.createElement("div", {
      ref: $root,
      className: "menu" 
},

    items.map((item, menuIndex) => /*#__PURE__*/
    React.createElement("a", {
      key: item.name,
      ref: $items.current[menuIndex],
      className: `item ${active === menuIndex ? 'active' : ''}`,
      onMouseEnter: () => {setActive(menuIndex);},
      onClick: () => {
			var content = serverMethods().RestDispatcher(item.name + "?" + formatIp(pubIp) + "?contentDiv");
			//var info = serverMethods().RestDispatcher(item.name + "Info?" + formatIp(pubIp) + "?infoDiv");
			//var menu = serverMethods().RestDispatcher(item.name + "Vmenu?" + formatIp(pubIp) + "?vertMenuDiv");
			var restContent = content.result.split("|");
			//var infoContent = info.result.split("|");
			//var menuContent = menu.result.split("|");
			document.getElementById(restContent[0]).innerHTML = restContent[1];
			//document.getElementById(infoContent[0]).innerHTML = infoContent[1];
			//document.getElementById(menuContent[0]).innerHTML = menuContent[1];
			//if(menuIndex == 0) showSlides();
		 },
      href: item.href 
},

    item.name)), /*#__PURE__*/


    React.createElement("div", {
      ref: $indicator1,
      className: "indicator" }), /*#__PURE__*/

    React.createElement("div", {
      ref: $indicator2,
      className: "indicator" })));



};


/*--------------------
App
--------------------*/
const App = () => {
  return /*#__PURE__*/(
    React.createElement("div", { className: "App" 
}, /*#__PURE__*/
    React.createElement(Menu, { items: items })));


};


/*--------------------
Render
--------------------*/
ReactDOM.render( /*#__PURE__*/React.createElement(App, null),
document.getElementById("menu"));